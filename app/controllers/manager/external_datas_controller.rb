class Manager::ExternalDatasController < Manager::HomeController
  before_action :set_my_global_variable

  #=== 管理共通（CSV一括登録画面表示) Common management (CSV bulk registration screen display)
  def csv_in
    @title = I18n.t("page_titles.csv_in",:name=>"勤務時間取込（既存連携）")
    @out_file_name = I18n.t("page_titles.index",:name=>"hogehoge")
    @cc = WorkTimeCsv.set_csv_form("work_time_csv")
    render :template => "manager/external_datas/work_time_csv/csv_in"

  end

  def csv_input
    #== 小さい関数 Small function
    find_rsw = ->(t_date,user_id){
      return ResultCargoWorker.where(:work_date=>t_date, :user_id=>user_id)
    }

    find_vacation = ->(t_date,user_id){
      return Vacation.find_by(:vacation_day=>t_date, :user_id=>user_id)
    }


    #== メイン処理 Main processing
    msgs = validate_params(params)
    if msgs.present?
      flash[:error_msgs] = msgs.map{|msg| "・" + msg.html_safe}
      @title = I18n.t("page_titles.csv_in",:name=>"勤務時間取込（既存連携）")
      @cc = WorkTimeCsv.set_csv_form("work_time_csv")
      return render :template => "manager/external_datas/work_time_csv/csv_in"
    end

    # 変数 Variables
    row_datas  = []
    t_date = Date.parse(params["t_date"])
    csv_file = params[:file][:csv].tempfile


    # CSV→オブジェクト変換 CSV to object
    CSV.foreach(csv_file.path, headers: true, encoding: 'SJIS:UTF-8') do |row|
      # create work_time_csv object
      row_data = WorkTimeCsv.create_from_csv_row(row)
      row_datas << row_data
    end


    # 参照系の変数 Reference variables
    vacation_types = VacationType.all.pluck(:time_sheet_name,:base_no,:id)
    names          = row_datas.filter{|d| d.validate_msg.blank?}.map(&:worker_name)
    users          = User.where("REPLACE(REPLACE(name,' ', ''),'　', '') in (?)",names)
    wokers         = Woker.get_latest(t_date).where(:login_id=>users.map(&:login_id))
    user_hash      = users.index_by{|user|
      key = user.name.gsub(/[ 　]/,"")
      key
    }

    # 行ごとに処理(オブジェクト変換済み) Process each row (object converted)
    row_datas.each do |data_line|
      next if data_line.validate_msg.present?
        worker_name = data_line.worker_name
        user = user_hash[worker_name]
        if user.blank?
          data_line.validate_msg << "該当従業員[#{worker_name}]は登録されていないか名寄せができません。"; next
        end

        work_type = data_line.work_type
        case work_type
        when "通常出勤(8-16)","休日出勤(8-16)","通常出勤(20-4)","休日出勤(20-4)","通常出勤(19-2)","休日出勤(19-2)"
          # -- ここから（共通部分） Common parts from here
          rcws = find_rsw.call(t_date,user.id)
          if rcws.blank?
            data_line.validate_msg << "[#{worker_name}]の作業配番が登録されていません"; next
          end

          s_time,e_time,bus_flg = data_line.conv_values(t_date)
          work_time = orver_time = 0
          if s_time.present? && e_time.present?
            l_work_time = WorkTimeAggregate.calc_legal_work_time(t_date,s_time,e_time,bus_flg)
            work_time, orver_time = l_work_time
          end
          
          rcws&.each do |rcw|
            in_data = {
              :s_time => s_time,
              :e_time => e_time,
              :work_time => work_time,
              :orver_time => orver_time,
              :bus_flg => bus_flg,
              :updated_at => Time.now,
              :updated_uid => get_uval(:login_id)
            }
            rcw.update(in_data)
          end
          # -- ここまで Common parts to here

          # 休暇データが無い場合、新規登録 If there is no vacation data, new registration
          if ["休日出勤(8-16)","休日出勤(20-4)","休日出勤(19-2)"].include?(work_type)
            t_date_vacation = find_vacation.call(t_date,user.id)
            if t_date_vacation.blank?
              # 対象日に休暇登録がない（「公○」で新規登録 No leave registration has been made for the target date (new registration under "Public ○")
              new_v = Vacation.template(:base_no=>6,:create_user=>User.find(get_uval(:id)))
              in_data = {
                :user_id => user.id,
                :login_id => user.login_id,
                :branch_cd => wokers.find_by_login_id(user.login_id)&.branch_cd,
                :vacation_day => t_date,
                :at_work => 1,
                :sts => 4
              }
              new_v.assign_attributes(in_data)
              v = Vacation.create_vacation(new_v.attributes)
            else
              # 対象日に休暇登録がある場合 → なにもしない If there is a leave registration for the target date, do nothing
            end
          end
        else
          unless work_type.match(/^通常出勤\(.*\)$|^休日出勤\(.*\)$/) # 勤怠が「通常出勤(*)」「休日出勤(*)」以外の場合--- If the work is not "normal attendance" or "holiday attendance"
            vt = vacation_types.find{|nm,_| nm==work_type}
            if vt.blank?
              data_line.validate_msg << "[#{worker_name}]の勤怠[#{work_type}]は登録されていません"; next
            end
            t_date_vacation = find_vacation.call(t_date,user.id)

            # 当日の休暇データが存在しない場合は新規登録 If there is no vacation data for the day
            if t_date_vacation.blank?
              t_date_vacation = Vacation.template(:base_no=>vt[1],:create_user=>User.find(get_uval(:id)))
              t_date_vacation.assign_attributes({
                :user_id => user.id,
                :login_id => user.login_id,
                :branch_cd => wokers.find_by_login_id(user.login_id)&.branch_cd,
                :vacation_day => t_date,
              })
              v = Vacation.create_vacation(t_date_vacation.attributes)
            end

            # 該当データが存在し、休暇種別が一致しない場合は更新 If the corresponding data exists and the vacation type does not match
            if t_date_vacation.base_no!=vt[1]
              t_date_vacation.assign_attributes({
                :base_no => vt[1],
                :vacation_type_id => vt[2],
                :updated_at => Time.now,
                :updated_uid => get_uval(:login_id)
              })
              t_date_vacation.auto_fill()
              t_date_vacation.clear_unused_fields()
              t_date_vacation.save
            end


            # 勤怠が「早遅」「遅出」「看Ａ」「看Ｐ」「介Ａ」「介Ｐ」「年Ａ」「年Ｐ」の場合は作業員データを更新 If the work is "early/late","late arrival","watch 1","watch 2","interview 1","interview 2","year 1","year 2", update worker data
            if VacationType.staggered.pluck(:base_no).include?(t_date_vacation&.base_no&.to_i)
              rcws = find_rsw.call(t_date,user.id)
              if rcws.blank?
                # data_line.validate_msg << "[#{worker_name}]の作業配番が登録されていません";  # data_line.validate_msg << "The work assignment for "[#{worker_name}] is not registered";
                next
              end

              s_time,e_time,bus_flg = data_line.conv_values(t_date)
              work_time = orver_time = 0
              if s_time.present? && e_time.present?
                l_work_time = WorkTimeAggregate.calc_legal_work_time(t_date,s_time,e_time,bus_flg)
                work_time, orver_time = l_work_time
              end
              
              rcws&.each do |rcw|
                in_data = {
                  :s_time => s_time,
                  :e_time => e_time,
                  :work_time => work_time,
                  :orver_time => orver_time,
                  :bus_flg => bus_flg,
                  :updated_at => Time.now,
                  :updated_uid => get_uval(:login_id)
                }
                rcw.update(in_data)
              end
              # -- ここまで to this point
            end
          end
        end
        
        # ----
        
      end

    flash["error_msgs"] = row_datas.filter{|d| d.validate_msg.present?}.map(&:validate_msg).flatten.map{|msg| "・" + msg.html_safe}
    flash["error_msgs"] << "・#{row_datas.filter{|d| d.validate_msg.blank?}.size}件の勤怠データを取り込みました。"

    # バックグラウンドジョブ登録 Register background job
    Batche::WorkTimeAggregate.delay.do(t_date.strftime("%Y%m%d"),t_date.strftime("%Y%m%d"))

    @title = I18n.t("page_titles.csv_in",:name=>"勤務時間取込（既存連携）")
    @cc = WorkTimeCsv.set_csv_form("work_time_csv")
    return render :template => "manager/external_datas/work_time_csv/csv_in"
  end


  private
  def set_my_global_variable
    @my_setting = {
      :def_where=>[],
      :back_links => [{:txt=>I18n.t("btn_labels.link_to",:to=>I18n.t("page_titles.menu")),
          :path=>{:controller=>:home ,:action => :menu} }],
      :multipart_flg=>false,
      }
  end

  def validate_params(params)
    msgs = []
    msgs << "CSVファイルが未選択です。" if params[:file].blank?
    msgs << "CSVファイルの形式が不正です。" if params[:file].present? && params[:file][:csv].content_type != "text/csv"
    msgs << "対象勤務日が未入力です。" if params[:t_date].blank?
    return msgs
  end

end

