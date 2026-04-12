class Operator::MyVacationsController < Operator::HomeController
  before_action :get_set_tdate
  before_action :set_my_global_variable
  # before_action :set_my_oth_variable,:only=>[:show,:edit,:update]
  skip_before_action :verify_authenticity_token,:only=>[:create]
  
  #=== 休暇登録画面

  def index
    @title = "休暇登録"
    @inc_js = ['operator/vacations']
    @post_url = url_for(:action=>:index) # 休暇登録リクエスト先URL

    @my_id = get_uval(:id)
    @today = Date.today
    @top_message = [] # 表示メッセージ一覧

    


    #JS制御用 
    @acquirable_vacation_days = @reserved_vacation_days = 0
    @l_hol_unset_flg = true
    
    @grid_setting = {l_index: 1, r_index: 4, col_size: 3}
    @datas = {}
    @tarm = [get_month(@t_date), get_month(@t_date,1)];
    @tarm.each.with_index do |tarm,index|
      vacation_lock = VacationBase6Lock.isLocked?(tarm[:year],tarm[:month],get_uval(:branch_cd))
      @tarm[index][:locked] = vacation_lock
    end


    all_dates_in_tarm = @tarm.map{|t| (t[:length][:begin_date]..t[:length][:end_date]).to_a}.flatten.sort
    vacations = Vacation.where(:login_id=>get_uval(:login_id),:vacation_day=>(all_dates_in_tarm[0]-10..all_dates_in_tarm[-1]+10)).index_by(&:vacation_day)
    wh_calendars = WhCalendar.where(:t_date=>(all_dates_in_tarm[0]-10..all_dates_in_tarm[-1]+10)).index_by(&:t_date)

    if wh_calendars.blank? || all_dates_in_tarm.size+20 != wh_calendars.size
      set_error("system_alert.blank_wh_calendar")
      redirect_to :controller=>:home,:action=>:error
      return
    end
    @wh_flg_list = wh_calendars.map{|date,wh| [date.strftime("%Y%m%d"),wh.wh_flg]}.to_h

    @tarm.each.with_index do |t_tarm,index|
      year = t_tarm[:year]
      month = t_tarm[:month]
      s_date = t_tarm[:length][:begin_date]
      e_date = t_tarm[:length][:end_date]
      locked = t_tarm[:locked]

      @datas[month] ||= {}
      
      wk_date = s_date
      
      # 公休日設定と公休日設定下限を取得　※公休日未設定の場合、-1をセット
      if index==1 #翌月
        holi_cnt = Vacation.where(:login_id=>get_uval(:login_id),:vacation_day=>(s_date..e_date),:base_no=>6).count
        if holi_cnt>0
          wh_sum = WhSummary.find_by(t_year:year,t_month:month)
          @acquirable_vacation_days = wh_sum.h_setting_min
          @l_hol_unset_flg = false
        else
          @acquirable_vacation_days = -1
        end
      end



      # s_dateの上方向およびe_dateの下方向に隣接する1公休日を0公休日でサンドイッチしているか調べる
      sandwich = {upper: false,under: false}
      tmp_s_date = s_date
      while @wh_flg_list[tmp_s_date.strftime("%Y%m%d")]==1
        tmp_s_date +=1
      end
      tmp_e_date = e_date
      while @wh_flg_list[tmp_e_date.strftime("%Y%m%d")]==1
        tmp_e_date -=1
      end

      @sandwich = {tmp_s_date.strftime("%Y%m%d") => false,tmp_e_date.strftime("%Y%m%d") => false}
      cnt = 0
      [[tmp_s_date,-1],[tmp_e_date,1]].each do |data|
        def_date,step = data
        cur_date = def_date
        loop_flg = true
        next if @wh_flg_list[(cur_date + step).strftime("%Y%m%d")]==0
        while loop_flg do
          raise "無限ループしています" if cnt == 999
          cur_date += step
          wh_flg = @wh_flg_list[cur_date.strftime("%Y%m%d")]
          if wh_flg==0
            loop_flg = false
            cur_vacation = vacations[cur_date]
            @sandwich[def_date.strftime("%Y%m%d")] = true if cur_vacation.present? && cur_vacation[:base_no]==6
          end
          cnt +=1
        end
      end


      # 曜日表記リスト
      day_of_week_list = I18n.t("date.abbr_day_names")
      while wk_date <= e_date do
        wday = wk_date.wday
        key = wk_date.strftime("%Y-%m-%d")
        vacation = vacations[wk_date]
        wh = wh_calendars[wk_date]
        day_info = {
          date: [wk_date.year,wk_date.month,wk_date.day,day_of_week_list[wday]],
          wday: wday,
          wh: wh,
          wh_flg: (wh.present? ? wh[:wh_flg] : 0),
          monthly: year.to_s + format("%02d",month),
          vacation: vacation,
          id_prefix: "vac_",
          # id_prefix: (index==0 ? "vac_cur_" : "vac_nex_"),
          click_events: "hundleClick(this,#{locked})",
          vacation_lock: 0,
        }
        day_info[:vacation_lock] = 1 if day_info[:wh_flg]==1 || @sandwich[wk_date] #&& vacations[wk_date][:sts]==1


        @datas[month][key] = day_info
        # 翌月のユーザ設定済の公休日をカウント
        if index==1
          @reserved_vacation_days +=1 if vacation && (vacation[:base_no] == 6 || vacation[:base_no] == 7 || vacation[:base_no] == 17) && day_info[:wh] && day_info[:wh_flg] == 0
        end
        wk_date += 1
      end
    end


    # 代休候補リスト：過去3か月までの公休〇（代休取得済は除外
    @work_day_onvac = Vacation.where(:base_no=>6,:login_id=>get_uval(:login_id),:at_work=>1).where("vacation_day >= ?",Date.today.ago(3.month)).order(:vacation_day).filter{|v|
      ck = true
      ck = false if v.sts==5
      sub = Vacation.find_by(:login_id=>v.login_id,:origin_date=>v.vacation_day)
      ck = false if sub.present?
      ck
    }

    # --- 「振替元日」候補リスト」 ---
    # フォーム形式： list
    # 属性       ： origin_date
    # 形式      ： yyyy-mm-dd（yyyy年m月d日振替）
    # 抽出条件  ： 同月度内の未消化の公休(base6)　および　同月度内の未消化の振休(base7)
    # UAT303   ： 過去日の振休は抽出条件から外すことで再振替不可としている。　管理課側で修正したい場合はコメントアウトしている行を使用する。その際、配番実績との不一致について対策要否を考えること(2025-10-09 大澤)
    @unused_vacations_str = {}
    @tarm.each.with_index do |t_tarm,index|
      year = t_tarm[:year]
      month = t_tarm[:month]
      wh_summary = WhSummary.find_by_get_month(t_tarm);

      today = Date.today
      base6_list = []
      # 公休リスト
      base6_in_tarm = Vacation.get_base6(get_uval(:id),:wh=>0,:where=>[["vacation_day >= ?",wh_summary.s_date],["vacation_day <= ?",wh_summary.e_date],["vacation_day >= ?",today]]).to_a
      base6_in_tarm = base6_in_tarm.filter{|vacation| vacation.sts!=4 && vacation.sts!=5 && Vacation.find_by(:login_id=>vacation.login_id,:origin_date=>vacation.vacation_day).blank?}
      # 振休取得済の公休リスト
      base7_in_tarm = Vacation.where(:user_id=>get_uval(:id),:base_no=>7).where("vacation_day >= ? and vacation_day <= ?",wh_summary.s_date,wh_summary.e_date).where("vacation_day >= ?",today).to_a
    # base7_in_tarm = Vacation.where(:user_id=>@user.id,:base_no=>7).where("vacation_day >= ? and vacation_day <= ?",wh_summary.s_date,wh_summary.e_date).where.not(:id=>nil,:origin_date=>@vacation.origin_date).to_a

      # 公休リストと振休取得済の公休リストを結合
      base6_list += base6_in_tarm if base6_in_tarm.present?
      base6_list += base7_in_tarm if base7_in_tarm.present?
      # 選択リスト用のソート、文字列変換
      base6_list = base6_list.sort_by{|vacation| vacation.base_no==6 ? vacation.vacation_day : vacation.origin_date}
        .map{|vacation| 
          str = vacation.base_no==6 ? 
            vacation.vacation_day.strftime('%Y-%m-%d') : 
            vacation.origin_date.strftime("%Y-%m-%d") + " (#{vacation.vacation_day.strftime("%Y年%-m月%-d日に振替え")})"
          value = vacation.base_no==6 ? vacation.vacation_day.strftime('%Y-%m-%d') : vacation.origin_date.strftime("%Y-%m-%d")
          [str,value]
        }
      @unused_vacations_str[year.to_s + format("%02d",month)] = base6_list;


    end



    # 休暇選択フォーム
    @vacation_type_lists = []
    # form_str_mapping = {"看Ａ"=>"午前看護","看Ｐ"=>"午後看護","介Ａ"=>"午前介護","介Ｐ"=>"午後介護",""}
    @vacation_type_lists << VacationType.getdatalist({:key=>:base_no,:text=>:time_sheet_name,:order=>:base_no,:where=>"base_no <> 1 and base_no <> 2 and base_no <> 3 and base_no <> 6 and base_no < 31"})
    @vacation_type_lists << VacationType.getdatalist({:key=>:base_no,:text=>:time_sheet_name,:order=>:base_no,:where=>"(base_no >= 31 and base_no < 35) or base_no = 41 or base_no = 42"}).map{|name,base_no| [Vacation::FullNameList.find{|_,cd| cd==base_no}[0],base_no]}
    @sform_setting = []
    @sform_setting << {key:"vacation_day",title:"休暇日",group:"0,1",ess:0,value:nil}
    @sform_setting << {key:"vacation_type",title:"休暇種別",group:"0",ess:0,value:@vacation_type_lists[0]}
    @sform_setting << {key:"arriv_time",title:"出勤希望時刻",group:"0",ess:0,value:Vacation::ReachTimeList,size:1,rel:['0','2','3','32','34','42'],event:{onchange:"set_time(this)"}}
    @sform_setting << {key:"leav_time",title:"退勤希望時刻",group:"0",ess:0,value:Vacation::LeavTimeList,size:1,rel:['0','2','31','33','41'],event:{onchange:"set_time(this)"}}
    @sform_setting << {key:"origin_date",title:"振替元日",group:"0",ess:1,value:[],size:1,rel:["7"],event:{}}
    @sform_setting << {key:"origin_date2",title:"休日出勤日",group:"0",ess:1,value:@work_day_onvac,size:15,rel:["6","17"],event:{onchange:"set_date(this)"}}
    @sform_setting << {key:"app_origin_date",title:"振替元日",group:"0",ess:0,value:"",size:14,rel:["7"],event:{}} # 休日出勤選択時に表示する振替元日
    @sform_setting << {key:"app_origin_date2",title:"休日出勤日",group:"0,1",ess:0,value:"",size:14,rel:["6","17"],event:{}} # 休日出勤選択時に表示する振替元日
    @sform_setting << {key:"com_vacation_day",title:"振替日",group:"1",ess:1,value:nil,size:14,rel:["6","17"],event:{onchange:"set_date(this)"}} # 休日出勤選択時に表示する振替日
    @sform_setting << {key:"end_date",title:"終了日",group:"0",ess:0,value:"",size:16,rel:["999"]||VacationType.getdatalist({:key=>:base_no,:text=>:time_sheet_name,:order=>:base_no}).map{|t| t[1]} - ["7"],event:{onchange:"set_date(this)"}}
    @sform_setting << {key:"vacation_type2",title:"半休",group:"0",ess:0,value:@vacation_type_lists[1]}
    @sform_setting << {key:"def_base_no",title:"変更前休暇種別",group:"-1",ess:0,rel:[]}
    @sform_setting << {key:"preselect_base_no",title:"前回選択休暇種別",group:"-1",ess:0,rel:[]}
  end



  #=== 休暇更新処理
  def create
    result = {}
    user  = User.find_by_id(get_uval(:id))
    if user.blank?
      result["user_not_found"] = {sts:"400",msg:"対象ユーザが見つかりません。"}
      return render :json=>result.to_json, :status => 200
    end
    
    vacation_keys = params.keys.filter{|key| key.match(/\d{7}/)}
    if vacation_keys.blank?
      result["vdate_not_found"] = {sts:"400",msg:"休暇登録リクエストが見つかりません。"}
      return render :json=>result.to_json, :status => 200
    end
    req = params.to_unsafe_h.slice(*vacation_keys)
    corrected = corrected_params(req)
    alert_messages = validate_params(user,corrected)
    if alert_messages.present?
      result = set_alert(alert_messages)
      return render :json=>result.to_json, :status => 200
    end
    vacations = build_vacations(user,corrected)
    success = false
    Vacation.transaction do
      # 登録済休暇データの削除
      delete_existing_vacations(vacations)
      # 休暇データの登録
      regist_vacations(vacations)
      success = true
    end if vacations.present?

    if success
      result = set_result(vacations)
    else
      result["process_failed"] = {sts:"400",msg:"登録処理に失敗しました。"}
    end

    return render :json=>result.to_json, :status => 200

  end

  
  private
  def set_my_global_variable
    @my_setting = {:table=>Vacation,
      :def_where=>[],
      :back_links => [{:txt=>I18n.t("btn_labels.link_to",:to=>I18n.t("page_titles.menu")),
          :path=>{:controller=>:home ,:action => :top} }],
      :multipart_flg=>false,
      }
    # @vacation_type = VacationType.getdatalist({:text=>:time_sheet_name,:order=>:base_no})
  end

  def set_my_oth_variable
    @wh = WhCalendar.find_by_t_date(@t_date)
    @vacation = Vacation.find_by({:user_id=>get_uval(:id),:vacation_day=>@t_date})
    if @vacation.blank?
      @vacation = Vacation.new({:user_id=>get_uval(:id),:vacation_day=>@t_date,
        :login_id=>get_uval(:login_id),:branch_cd=>get_uval(:branch_cd),:sts=>0 })
    end
    @form_setting=[];@button_setting=[]
    if @wh[:wh_flg]==1
      if @vacation.new_record?
      else
        @title="休日出勤依頼"
        case @vacation[:sts]
        when 0  #未承認→振替日入れて承認　or 理由入れて差戻
          @form_setting << {:title=>Vacation.human_attribute_name(:sts),:key=>:sts,:io=>0}
          @form_setting << {:title=>"振替日",:key=>:origin_date,:io=>1}
          @form_setting << {:title=>Vacation.human_attribute_name(:reason),:key=>:reason,:io=>1}
          @button_setting << ["差戻(拒否)","addSts('sts',2);doUpdate();","btn-destroy"]
          @button_setting << ["承認","addSts('sts',1);doUpdate();","btn-update"]
        when 1  #承認済み→振替日表示のみ
          @form_setting << {:title=>"振替日",:key=>:origin_date,:io=>0}
          @button_setting << ["承認を解除","addSts('sts',0);doUpdate();","btn-destroy"]
        when 2  #差戻→理由表示のみ
          @form_setting << {:title=>Vacation.human_attribute_name(:reason),:key=>:reason,:io=>0}
          @button_setting << ["差戻(拒否)を解除","addSts('sts',0);doUpdate();","btn-destroy"]
        end
      end
    else
      @title="休暇申請登録"
      @vacation_list = VacationType.getdatalist({:key=>:base_no,:text=>:time_sheet_name,:order=>:base_no,:where=>"base_no <> 1"})
      if @vacation.new_record?
        [:base_no,:at_work,:origin_date,:leav_time].each{|key|
          @form_setting << {:title=>Vacation.human_attribute_name(key),:key=>key,:io=>1}
        }
        @button_setting << ["申請","doUpdate();","btn-update"]
      else
        case @vacation[:sts]
        when 0  #未承認→変更or取り下げ
          [:base_no,:at_work,:origin_date,:leav_time].each{|key|
            @form_setting << {:title=>Vacation.human_attribute_name(key),:key=>key,:io=>1}
          }
          @button_setting << ["取下","doDelete();","btn-destroy"]
          @button_setting << ["申請変更","doUpdate();","btn-update"]
        when 1  #承認済み→表示のみ
          [:base_no,:at_work,:origin_date,:leav_time].each{|key|
            @form_setting << {:title=>Vacation.human_attribute_name(key),:key=>key,:io=>0}
          }
        when 2  #差戻→理由表示 & 変更or取り下げ
          [:base_no,:at_work,:origin_date,:leav_time,:reason].each{|key|
            @form_setting << {:title=>Vacation.human_attribute_name(key),:key=>key,:io=>0}
          }
          @button_setting << ["取下","doDelete();","btn-destroy"]
        end
      end
    end
  end



  private 
  
  #=== 休暇更新処理（パラメータ正規化
  def corrected_params(requests)
    corrected = {}
    requests.each do |key,param|
      corrected[key] = {}
      corrected[key][:vacation_day] = Date.strptime(param["vacation_day"],"%Y%m%d")
      corrected[key][:base_no] = param["base_no"].to_i

      case corrected[key][:base_no]
      when 2,3
        corrected[key][:leav_time] = param["leav_time"]
        corrected[key][:arriv_time] = param["arriv_time"]
      when 6
        corrected[key][:at_work] = param["at_work"]
      when 7,17
        corrected[key][:origin_date] = Date.strptime(param["origin_date"],"%Y%m%d") if param["origin_date"].present? && param["origin_date"] =~ /\d{7}/
      when 31,33,41
        corrected[key][:leav_time] = param["leav_time"]
      when 32,34,42
        corrected[key][:arriv_time] = param["arriv_time"]
      else
        Rails.logger.warn "未対応のbase_no: #{corrected[key][:base_no]}"
      end
    end
    corrected

  end

  # バリデーション
  def validate_params(user,corrected)
    alert_messages = {}
    corrected.each do |key,param|
      msgs = []
      msgs << "休暇日が未入力です。" if param[:vacation_day].blank?
      msgs << "休暇種別が未入力です。" if param[:base_no].blank?
      applecable = Applicable.get_applicable(2,param[:vacation_day])
      woker = Woker.find_by(:login_id=>user.login_id,:applicable=>applecable)
      msgs << "配番作業員データが見つかりません。" if woker.blank?
      
      if msgs.blank?
        case param[:base_no]
        when 7
          if param[:origin_date].present?
            msgs << "休暇日と同日の振替元日が指定されています。" if param[:vacation_day]==param[:origin_date]
            origin = Vacation.unscoped.find_by(user_id: user.id, vacation_day: param[:origin_date], base_no: 6)
            if msgs.blank? && origin.present?
              ck_result = origin.can_take_vacation(param[:vacation_day], param[:base_no], false, true)
              msgs << ck_result[:msg] unless ck_result[:result]==200
            end
          else
            msgs << "「振替元日」が未入力です。"
          end
        when 17
          if param[:origin_date].present?
            msgs << "休暇日と同日の休日出勤日が指定されています。" if param[:vacation_day]==param[:origin_date]
            origin = Vacation.find_by(user_id: user.id, vacation_day: param[:origin_date], base_no: 6, sts: [4,5])
            if msgs.blank? && origin.present?
              ck_result = origin.can_take_vacation(param[:vacation_day], param[:base_no], false, false)
              msgs << ck_result[:msg] unless ck_result[:result]==200
            end
          else
            msgs << "「休日出勤日」が未入力です。"
          end
        end
      end
      alert_messages[key] = msgs if msgs.size>0
    end
    alert_messages
  end


  def set_alert(alert_messages)
    ret = {}
    alert_messages.each do |key,msgs|
      t_date = Date.strptime(key,"%Y%m%d")
      ret[t_date.strftime("%Y年%-m月%-d日")] = {"sts"=>"400", "msg"=>msgs.join("\n")}
    end
    ret
  end

  def set_result(vacations)
    ret = {}
    vacations.each do |vacation|
      msg = vacation.base_no==0 ? "休暇登録を削除しました。" : "正常に休暇登録されました。"
      ret[vacation.vacation_day.strftime("%Y年%-m月%-d日")] = {"sts"=>"200", "msg"=>msg}
    end
    ret
  end

  def build_vacations(user,corrected)
    vacations = []
    corrected.each do |key,param|    
      applecable = Applicable.get_applicable(2,param[:vacation_day])
      woker = Woker.find_by(:login_id=>user.login_id,:applicable=>applecable)

      # --
      if param[:base_no] == 7
        origin_vacation = Vacation.unscoped.find_by(:user_id=>user.id,:vacation_day=>param[:origin_date],:base_no=>6)
        if origin_vacation.present?
          param[:vacation_id] = origin_vacation.id
        end
      elsif param[:base_no] == 17
        origin_vacation = Vacation.find_by(:user_id=>user.id,:vacation_day=>param[:origin_date],:base_no=>6,:sts=>[4,5])
        if origin_vacation.present?
          param[:vacation_id] = origin_vacation.id
        end
      end

      param[:user_id] = user[:id]
      param[:login_id] = user[:login_id]
      param[:branch_cd] = woker[:branch_cd]
      param[:sts] = 0
      param[:vacation_type_id] = VacationType.find_by(:base_no=>param[:base_no]).try(:id)
      param[:app_at] = Time.now
      param[:authorizer_id] = user[:id]
      param[:authorizer_name] = user[:name]
      param[:approval_at] = Time.now
      param[:created_at] = Time.now
      param[:created_uid] = user[:login_id]
      param[:updated_at] = Time.now
      param[:updated_uid] = user[:login_id]

      new_vacation = Vacation.new(param)
      new_vacation.auto_fill
      vacations << new_vacation
    end
    vacations
  end

  def delete_existing_vacations(vacations)
    user_id = vacations.first.user_id
    days = vacations.map(&:vacation_day)
    existing = Vacation.unscoped.where(:user_id=>user_id,:vacation_day=>days)
    if vacations.any?{|vac| vac.origin_date.present?}
      origin = Vacation.unscoped.where(:user_id=>user_id,:origin_date=>vacations.map(&:origin_date),:base_no=>[7,17]).where.not(:id=>existing.pluck(:id))
      existing += origin if origin.present?
    end
    existing.each do |vacation|
      vacation.remove_and_restore_origin_vacation
    end
  end

  def regist_vacations(vacations)
    return if vacations.blank?
    vacations.each do |vacation|
      next if vacation.base_no==0
      if vacation.vacation_id.present?
        if vacation.base_no == 7
          Vacation.find_by(:id=>vacation.vacation_id).update!(:deleted_at=>Time.now,:deleted_uid=>vacation.created_uid,:reason=>"振休取得(to #{vacation.vacation_day.strftime("%Y%m%d")})")
        elsif vacation.base_no == 17
          Vacation.find_by(:id=>vacation.vacation_id).update(:sts=>5,:reason=>"代休取得(to #{vacation.vacation_day.strftime("%Y%m%d")})",:updated_at=>Time.now,:updated_uid=>vacation.created_uid)
        end
      end
      vacation.save!
    end
  end




end