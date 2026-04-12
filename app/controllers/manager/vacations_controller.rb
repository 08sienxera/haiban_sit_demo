class Manager::VacationsController < Manager::HomeController
  before_action :get_set_tdate
  before_action :set_my_global_variable
  before_action :set_my_oth_variable,:only=>[:edit,:update]


  #=== 開発中（テスト
  def test_run
    t_year = 2025
    t_month = 7
    if Rails.env.production?
      return render :json=>"本番環境では無効です。（懸案対応用の一時的な機能のため、後に削除します。）"
    end

    if params[:mord] == "add6"
      wh = WhSummary.find_by(:t_year=>t_year, :t_month=>t_month);
      vacations = Vacation.where(:vacation_day=>wh[:s_date]..wh[:e_date]);
      vacations.select{|v| v.vacation_day.wday!=0}.each {|v| v.destroy};

      msg = Vacation.after_set_add6(t_year,t_month,"xadmin");
      render :json=>{:msg=>msg,:params=>params}
    end
    if params[:mord] == "reset6"
      wh = WhSummary.find_by(:t_year=>t_year, :t_month=>t_month);
      vacations = Vacation.where(:vacation_day=>wh[:s_date]..wh[:e_date]);
      vacations.select{|v| v.vacation_day.wday!=0}.each {|v| v.destroy};
      render :json=>params
    end
  end

  #=== 休暇管理画面を表示
  def index
    @title="休暇管理"
    @t_tarm = get_month(@t_date)
    # 月度の前後10日を含めて取得
    @is_futurity = (@t_tarm[:length][:begin_date] >= @today)
    @calendar = Vacation.load_calendar(@t_tarm[:length][:begin_date]-10,@t_tarm[:length][:end_date]+10,:t_date=>@t_tarm[:length][:begin_date])
    # return render :json=>@calendar
    if @calendar[:wh].blank?
      session[:t_date] = nil
      flash[:error_msgs] = I18n.t("system_alert.blank_wh_calendar")
      redirect_to :controller => :home,:action=>:menu
      return
    end
    @wh_summary = WhSummary.find_by_get_month(@t_tarm)
    @inc_js= ["manager/vacations","eventUtil"]
    @add6_btn_lock = false # 不足公休自動設定ボタン　活性・非活性

    
    
    # 前後月度の末端日で法廷公休日につづく休暇を取得
    # <><<><><><><><><><>><><><>><><><><><><>><<><<<>><<>><

    @constraint_check_data = {:continuous_date=>[]}

    wh = @calendar[:wh]
    members = @calendar[:menbers]
    vacations = @calendar[:vacations]

    s_date, e_date = @t_tarm[:length].values_at(:begin_date,:end_date)
    [[s_date,-1],[e_date,1]].each do |def_date,step|
      ck_tdate = def_date + step

      t_wh = wh[ck_tdate] || WhCalendar.find_by_t_date(ck_tdate)
      unless t_wh
        set_error("system_alert.blank_wh_calendar")
        redirect_to :controller =>:home,:action=>:error
        return
      end
      wh_flg = t_wh[:wh_flg]
      if wh_flg==1
        @constraint_check_data[:continuous_date]<< def_date.strftime("%Y%m%d")
      end
    end
    
    tmp_s_date = s_date;
    while wh[tmp_s_date].present? && wh[tmp_s_date][:wh_flg]==1
      tmp_s_date +=1
    end
    tmp_e_date = e_date;
    while wh[tmp_e_date].present? && wh[tmp_e_date][:wh_flg]==1
      tmp_e_date -=1
    end
    
    members.each do |member|
      rm_flg = true
      login_id = member["login_id"]
      @constraint_check_data[login_id] ||= {}
      m_vacations = @calendar[:vacations][login_id]
      if m_vacations.present?
        # -- 月次範囲の前後1日を対象に法定休日との連続チェック
        # -- 法定休日のサンドウィッチチェック
        [[tmp_s_date,-1],[tmp_e_date,1]].each do |def_date,step|
          cur_date = def_date

          n_wh = wh[cur_date += step] || WhCalendar.find_by_t_date(cur_date += step)
          unless n_wh
            set_error("system_alert.blank_wh_calendar")
            redirect_to :controller =>:home,:action=>:error
            return
          end
          nwh_flg = n_wh[:wh_flg]

          if nwh_flg==1
            loop_flg = true
            while loop_flg do
              cur_date += step
              wh_flg = wh[cur_date][:wh_flg]
              if wh_flg==0
                loop_flg = false
                tdate_vacation = m_vacations[cur_date]
                if tdate_vacation && tdate_vacation[:base_no]==6
                  rm_flg = false
                  @constraint_check_data[login_id][def_date.strftime("%Y%m%d")] =  cur_date.strftime("%Y%m%d")
                end
              end
            end
          end
        end
      end
      @constraint_check_data.delete(login_id) if rm_flg
    end

    
    # ブランチ一覧
    t_branches = Branche.where(:cd=>Branche::WorkerBranchCd).pluck(:cd,:name).map{|cd,name| [name,cd]}

    # 操作可能なブランチ一覧
    permitted_branch = []
    user = User.find_by_id(get_uval(:id))
    if user.present?
      case user.auth_flg
      when 0,1,2
        @add6_btn_lock = true # 不足公休自動設定ボタン　活性・非活性
      when 3
        permitted_branch << user.branch_cd
      when 4,5
        permitted_branch = t_branches.map {|_,cd| cd}
      else
      end
    end
    @allowed_branches = permitted_branch

    # 公休予定確定済みのグループを取得
    locked_branches = VacationBase6Lock.get_locked_branch_cd_list(@t_tarm[:year],@t_tarm[:month])

    # 〆、〆解除　リクエストURL
    lock_url = url_for(:action=>:base6_lock)
    unlock_url = url_for(:action=>:base6_unlock)    

    
    # 〆ボタン用パラメータ
    keys = ["all",*t_branches.map{|_,cd| cd}]
    @vacation_lock_buttons = {}
    keys.each do |key|
      manager_flg = is_manager? || is_admin?
      name = key=="all" ? "全体" : t_branches.find{|_,cd| cd==key}[0]
      locked = key== "all" ? locked_branches.length==t_branches.length : locked_branches.include?(key)
      if manager_flg
        @add6_btn_lock = locked
      elsif permitted_branch.include?(key)
        @add6_btn_lock = locked
      end
      @vacation_lock_buttons[key] = {
        button_text: name + (locked ? "〆解除" : "〆"),
        request_url: locked ? unlock_url : lock_url,
        class: locked ? "lock" : "",
        pushable: key=="all" ? manager_flg : permitted_branch.include?(key),
        t_branch: key=="all" ? t_branches.map{|_,cd| cd}.join(",") : key
      }
    end
    
    @def_branch_cd = params[:def_branch_cd]&.to_i || User.find_by_id(get_uval(:id))&.branch_cd&.to_i

  end

  def base6_lock
    msg = []
    t_year,t_month,t_branch_cd = params.values_at(:t_year,:t_month,:t_branch_cd)

    t_branch_list = t_branch_cd.split(",")
    t_branch_list.each do |branch_cd|
      VacationBase6Lock.lock(get_uval(:login_id),t_year,t_month,branch_cd)
    end
    msg << "・対象グループの公休予定を確定しました。"
    # output = create_vacation_calendar_excel(t_year,t_month,t_branch_list)
    # msg << "・休暇カレンダーを作成しました。" if output.present?
    # ----------------------------------------------------


    flash[:msg] = msg
    redirect_to :action=>:index; return;
  end
  def base6_unlock
    t_year,t_month,t_branch_cd = params.values_at(:t_year,:t_month,:t_branch_cd)
    t_branch_cd.split(",").each do |branch_cd|
      VacationBase6Lock.unlock(get_uval(:login_id),t_year,t_month,branch_cd)
    end
    flash[:msg] = "対象グループの公休予定確定を解除しました。"
    redirect_to :action=>:index; return;
  end


  #=== 各種自動割当処理　他
  def create
    queue = "vacations#{params[:mord]}#{params[:t_year]}#{params[:t_month]}"
    case params[:mord]
    when "init6"
      job = DelayedJob.find_by_queue(queue)
      if job.blank?
        Vacation.delay(queue: queue).set_init6(queue,params[:t_year],params[:t_month],get_uval(:login_id))
        ret = {:msg=>"法定休日の公休日設定を予約しました。",:sts=>303}
      else
        ret = {:msg=>"法定休日の公休日設定実行中です。しばらくお待ちください。",:sts=>303}
      end
    when "add6"
      job = DelayedJob.find_by_queue(queue)
      if job.blank?
        Vacation.delay(queue: queue).set_add6(queue,params[:t_year],params[:t_month],get_uval(:login_id))
        ret = {:msg=>"不足公休日の自動割り当てを予約しました。",:sts=>303}
      else
        ret = {:msg=>"不足公休日の自動割り当て実行中です。しばらくお待ちください。",:sts=>303}
      end
    when "onoff6"
      ret = {:sts=>"err"}
      if params[:t_date].present? && params[:t_date] =~ /\d{8}/
        t_date = Date.strptime(params[:t_date], "%Y%m%d")
        @user = User.find_by_id(params[:user_id])
        if @user.present?
          @worker = Woker.find_by({:applicable=>Applicable.get_applicable(2,t_date),:login_id=>@user[:login_id]})
          if @worker.present?
            ret = {:sts=>"",:login_id=>@user[:login_id],:vacation_day=>params[:t_date]}
            vacation = Vacation.find_by(:user_id=>@user[:id],:vacation_day=>t_date)
            if vacation.blank?
              base_no = 6
              vtype = VacationType.select(:id).find_by_base_no(base_no)
              Vacation.create_vacation({
                :user_id => @user[:id],
                :login_id => @user[:login_id],
                :branch_cd => @worker[:branch_cd],
                :vacation_day => t_date,
                :vacation_type_id => vtype[:id],
                :base_no => base_no,
                :sts => 0,
                :created_uid => get_uval(:login_id),
                :updated_uid => get_uval(:login_id),
              })
              ret[:sts]="create"
            elsif vacation[:base_no] == 6
              vacation.destroy
              ret[:sts]="delete"
            end
          end
        end
      end
    when "onoff6atWork"
      ret = {:sts=>"err"}
      if params[:t_date].present? && params[:t_date] =~ /\d{8}/
        t_date = Date.strptime(params[:t_date], "%Y%m%d")
        @user = User.find_by_id(params[:user_id])
        if @user.present?
          vacation = Vacation.find_by(:user_id=>@user[:id],:vacation_day=>t_date)
          if vacation.present?
            ret = {:sts=>"",:login_id=>@user[:login_id],:vacation_day=>params[:t_date]}
            if vacation[:at_work]==1
              vacation[:at_work]=2
            else
              vacation[:at_work]=1
            end
            if vacation[:approval_at].blank?
              vacation[:sts]=1
              vacation[:authorizer_id]=get_uval(:login_id)
              vacation[:authorizer_name]=get_uval(:name)
              vacation[:approval_at]=Time.now
            end
            vacation[:updated_uid]=get_uval(:login_id)
            vacation.save!
            ret[:sts]= vacation[:at_work].to_s
          end
        end
      end
    else
      ret = {:msg=>"指定の実行は登録されていません。",:sts=>404}
    end
    render :json => ret.to_json, :status => 200
  end

  #=== 休暇代行登録画面を表示
  def edit
    # before_action :set_my_oth_variable,:only=>[:edit,:update]
  end

  #=== 休暇代行登録処理
  def update
    begin
      # パラメータの検証と初期化
      corrected = corrected_params(params.to_unsafe_h)
      # バリデーション
      alert_messages = validate_params(corrected)
      if alert_messages.present?
        @input = corrected
        @cc.setpostdata(params[:Vacation_in])
        set_form_aleat(@cc,alert_messages);
        render :action => :edit; return
      end

      # 休暇データの作成
      app_user = User.find(get_uval(:id))
      vacations = build_vacations(corrected,app_user)
      Vacation.transaction do
        # 登録済休暇データの削除
        delete_existing_vacations(vacations)
        # 休暇データの登録
        regist_vacations(vacations)
      end if vacations.present?

      # 実行結果メッセージの作成
      msg = build_result_message(vacations)
      flash[:msg] = msg
      # リダイレクト
      redirect_to :action => :index, :def_branch_cd => @worker[:branch_cd]
      return
    rescue ActiveRecord::RecordNotUnique => e
      set_error("system_alert.allrady_exists",nil,true,{:name=>@cc.getparamdata(@my_setting[:table_keys],"title"),:val=>@cc.getparamdata(@my_setting[:table_keys],"v_value")})
      redirect_to :controller =>:home,:action=>:error
      return
    rescue => e
      if Rails.env=="development" || Rails.env=="test"
        raise e; return
      end
      set_error("system_errors.update")
      redirect_to :controller =>:home,:action=>:error
      return
    end
    redirect_to :action => :index, :def_branch_cd => @worker[:branch_cd]
  end


  # 休暇承認画面を表示（仕様変更により未使用
  def show
    @mord = params[:id]
    @cc = @my_setting[:table].set_list_form(@my_setting[:table].model_name.name)
    @ss = Common::CommonClass.new(@cc.getgname)
    @ss.set_serch_params(@cc)
    @ss.setpostdata(params,session[:serch_data])
    case @mord
    when "0"
      @title="休暇申請未承認一覧"
      def_where = "base_no<>1 and sts=0"
      #検索項目要調整
    when "2"
      @title="休日出勤依頼差戻・未承認一覧"
      def_where = "base_no=1 and sts in (0,2)"
      #検索項目要調整
    else
      def_where = "sts=0"
    end
    sql_where = @ss.mksqlwhere(def_where)

    @datas = Vacation.paginate(:page => get_page(params,@cc), :per_page => LIST_LIMIT).
    includes([:user]).
    references(:user).
    where(sql_where).order("vacations.app_at desc")
    @my_setting[:back_links] << {:txt=>I18n.t("btn_labels.link_to",:to=>"休暇管理"),:path=>{:action => :index} }
  end



  



  # 休暇申請一括承認画面を表示（仕様変更により未使用
  def update_all
    @title="休暇申請一括承認"
  end

  #=== 休暇削除処理
  def destroy
    user = User.find_by_id(params[:id])
    vacation = Vacation.find_by({:user_id=>user[:id],:vacation_day=>@t_date})
    if vacation.blank?
      flash[:msg] = I18n.t("system_messages.not_fund")
      def_branch_cd = nil
    else
      def_branch_cd = vacation[:branch_cd]
      vacation.remove_and_restore_origin_vacation
      flash[:msg] = "#{user[:name]}の#{@t_date.strftime("%Y/%m/%d")}の休暇申請を削除しました。"
    end
    redirect_to :action=>:index,:def_branch_cd=>def_branch_cd
  end
  
  private
  def set_my_global_variable
    @my_setting = {:table=>Vacation,
      :def_where=>[],
      :back_links => [{:txt=>I18n.t("btn_labels.link_to",:to=>I18n.t("page_titles.menu")),
          :path=>{:controller=>:home ,:action => :menu} }],
      :multipart_flg=>false,
      }
    @today = Date.today
  end


  def set_my_oth_variable
    @wh     = WhCalendar.find_by_t_date(@t_date)
    @user   = User.find_by_id(params[:id])
    @worker = Woker.find_by({:applicable=>Applicable.get_applicable(2,@t_date),:login_id=>@user[:login_id]})

    # 
    [
      [@wh    , "system_alert.blank_wh_calendar"],
      [@user  , "system_messages.not_fund"      ],
      [@worker, "system_messages.not_fund"      ],
    ].each {|var,error|
      next if var.present?
        flash[:error_msgs] = I18n.t(error)
        redirect_to :controller => :home,:action=>:menu
        return
    }


    @vacation = Vacation.find_or_initialize_by(:user_id=>params[:id],:vacation_day=>@t_date) do |vac|
      vac[:login_id] = @worker[:login_id]
      vac[:branch_cd] = @worker[:branch_cd]
      vac[:sts] = 0
    end

    @title = "休暇代行更新"
    @title = "休暇代行登録" if @vacation.new_record?
    @title = "振休代行登録" if @vacation.holiday_work?


    # --- 「振替元日」候補リスト」 ---
    # フォーム形式： list
    # 属性       ： origin_date
    # 形式      ： yyyy-mm-dd（yyyy年m月d日振替）
    # 抽出条件  ： 同月度内の未消化の公休(base6)　および　同月度内の未消化の振休(base7)
    # UAT303   ： 過去日の振休は抽出条件から外すことで再振替不可としている。　管理課側で修正したい場合はコメントアウトしている行を使用する。その際、配番実績との不一致について対策要否を考えること(2025-10-09 大澤)
    wh_summary = WhSummary.find_by_tdate(@t_date)
    today = Date.today
    base6_list = []
    # 公休リスト
    base6_in_tarm = Vacation.get_base6(@user.id,:wh=>0,:where=>[["vacation_day >= ?",wh_summary.s_date],["vacation_day <= ?",wh_summary.e_date],["vacation_day >= ?",today]]).where.not(:id=>@vacation.id).to_a
    base6_in_tarm = base6_in_tarm.filter{|vacation| vacation.sts!=4 && vacation.sts!=5 && Vacation.find_by(:login_id=>vacation.login_id,:origin_date=>vacation.vacation_day).blank?}
    # 振休取得済の公休リスト
    base7_in_tarm = Vacation.where(:user_id=>@user.id,:base_no=>7).where("vacation_day >= ? and vacation_day <= ?",wh_summary.s_date,wh_summary.e_date).where.not(:id=>nil,:origin_date=>@vacation.origin_date).where("vacation_day >= ?",today).to_a
    # base7_in_tarm = Vacation.where(:user_id=>@user.id,:base_no=>7).where("vacation_day >= ? and vacation_day <= ?",wh_summary.s_date,wh_summary.e_date).where.not(:id=>nil,:origin_date=>@vacation.origin_date).to_a
    # 公休リストと振休取得済の公休リストを結合
    base6_list += base6_in_tarm if base6_in_tarm.present?
    base6_list += base7_in_tarm if base7_in_tarm.present?
    # 選択リスト用のソート、文字列変換
    base6_list = base6_list.sort_by{|vacation| vacation.base_no==6 ? vacation.vacation_day : vacation.origin_date}
      .map{|vacation| 
        vacation.base_no==6 ? 
        vacation.vacation_day.strftime('%Y-%m-%d') : 
        vacation.origin_date.strftime("%Y-%m-%d") + " (#{vacation.vacation_day.strftime("%Y年%-m月%-d日に振替え")})"
      }
    
    # 登録済休暇が振休の場合、選択リストの先頭に現在指定している「振替元日」を表示する
    base6_list = [@vacation.origin_date.strftime('%Y-%m-%d'), *base6_list] if @vacation&.base_no==7
    @holiday_work_data_list = base6_list

    # --- 「休日出勤日」候補リスト」 ---
    # フォーム形式  -> datalist
    # 属性         -> origin_date2
    @holiday_work_list = Vacation.get_hol_work_vacation(@user[:id]).map{|vac| vac[:vacation_day].strftime('%Y-%m-%d')}
    @holiday_work_list = [@vacation.origin_date.strftime('%Y-%m-%d'), *@holiday_work_list] if @vacation.base_no==17 # 登録済休暇が代休の場合、選択リストの先頭に現在指定している「休日出勤日」を追加
    
    # common_class の初期化
    @cc = Vacation.set_input_form("#{Vacation.model_name.name}_in")
    init_common_class_to_edit(@cc,@vacation,@holiday_work_data_list,@holiday_work_list)

    @my_setting[:back_links] << {:txt=>I18n.t("btn_labels.link_to",:to=>"休暇管理"),:path=>{:action => :index,:def_branch_cd=>@worker[:branch_cd]} }
    @my_setting[:tbl_optins] = {:class=>"soloidline",:not_ess_msg=>"on"}
  end


  def init_common_class_to_edit(common_class, vacation, unused_vacations, holiday_work_list)
    @form_options = []
    common_class.setdbdata(vacation)
    common_class.setparams("vacation_id",{"title"=>"ID","type"=>"hidden",'size'=>"2","maxlength"=>"9","inputFlg"=>1,"essFlg"=>0,"align"=>"C","value"=>vacation[:id]})
    common_class.setparams("mord",{"title"=>"MORD","type"=>"hidden",'size'=>"5","maxlength"=>"5","inputFlg"=>1,"essFlg"=>0,"align"=>"C","value"=>"edit"})

    if vacation.new_record?
      common_class.setparam("mord","value","new")
    else 
      case vacation[:base_no]
      when 6
        if vacation.holiday_work?
          @form_options << {:selector=>"#delete_btn",:option=>"disabled",:value=>true}
          common_class.setparam('vacation_day','readonly',true)
          common_class.setparam('base_no','value',"17")
          common_class.setparam('base_no','inputflg',0)
          common_class.setparam('base_no','readonly',true)
          common_class.setparam('origin_date2','title','振替日')
          common_class.setparam('origin_date2','ess',1)
          if vacation.holiday_work_with_subvacation?
            sv = Vacation.find_by_vacation_id(vacation.id)
            common_class.setparam('origin_date2','value',sv.vacation_day.strftime("%Y/%m/%d")) if sv.present?
            common_class.setparam('origin_date2','readonly',true)
            common_class.setparam('origin_date2','msg',"変更の場合は代休取得日を選択して登録し直してください")
          end
        end
      when 7
        if vacation.origin_date < Date.today
          @form_options << {:selector=>"select#origin_date",:option=>"disabled",:value=>true}
          @form_options << {:selector=>"#update_btn",:option=>"disabled",:value=>true}
          @form_options << {:selector=>"#delete_btn",:option=>"disabled",:value=>true}
          common_class.setparam('origin_date','value',vacation[:origin_date].strftime("%Y/%m/%d"))
          common_class.setparam('origin_date','msg',"変更の場合は移動したい日をあらためて選択して登録し直してください")
        end
      when 17
        common_class.setparam('origin_date2','value',vacation[:origin_date].strftime("%Y/%m/%d"))
      end
    end    

    # 振休、代休の候補リスト
    common_class.setparam('origin_date','type','select')
    common_class.setparam('origin_date','list',unused_vacations)
    common_class.setparam('origin_date2','bwd',build_datalist_html(holiday_work_list))


  end



  def build_datalist_html(holiday_work_list)
    html = ""
    html += "<datalist id='l_origin_date2'>"
    html += holiday_work_list.map{|vacation_day| "<option value='#{vacation_day}'></option>"}.join("\r")
    html += "</datalist>"
    html
  end

  def corrected_params(original_params)
    input = original_params[:Vacation_in]

    corrected = {}
    corrected[:user_id] = original_params["id"]
    corrected[:vacation_day] = Date.strptime(input[:vacation_day],"%Y/%m/%d")
    if input[:base_no].present?
      corrected[:base_no] = input[:base_no].to_i
    else
      corrected[:base_no] = 2
    end
    corrected[:vacation_end_day] = input[:vacation_end_day]!="" ? Date.strptime(input[:vacation_end_day],"%Y/%m/%d") : nil

    case corrected[:base_no]
    when 2,3
      corrected[:leav_time] = original_params[:leav_time]
      corrected[:arriv_time] = original_params[:arriv_time]
    when 6
      corrected[:at_work] = input[:at_work]
    when 7
      corrected[:origin_date] = Date.strptime(original_params[:origin_date],"%Y-%m-%d") if original_params[:origin_date].present?
    when 17
      corrected[:origin_date] = Date.strptime(input[:origin_date2],"%Y/%m/%d") if input[:origin_date2].present?
      if input[:sts]=="4" || input[:sts]=="5"
        origin_date = corrected[:origin_date]
        vacation_day = corrected[:vacation_day]
        corrected[:origin_date] = vacation_day
        corrected[:vacation_day] = origin_date
      end
    when 31,33,41
      corrected[:leav_time] = original_params[:leav_time]
    when 32,34,42
      corrected[:arriv_time] = original_params[:arriv_time]
    else
      Rails.logger.warn "未対応のbase_no: #{corrected[:base_no]}"
    end
    corrected

  end


  def validate_params(corrected)
    alert_messages = {}

    alert_messages[:vacation_day] = "休暇日が未入力です。" if corrected[:vacation_day].blank?
    alert_messages[:base_no] = "休暇種別が未入力です。" if corrected[:base_no].blank?
    return alert_messages if alert_messages.present?

    if corrected[:vacation_end_day].present?
      start_day = corrected[:vacation_day] + 1
      end_day = corrected[:vacation_end_day]
      if Vacation.where(:user_id=>corrected[:user_id],:vacation_day=>start_day..end_day).exists?
        alert_messages[:vacation_end_day] = "指定期間内に既に休暇登録があります。"
      end
    end
    return alert_messages if alert_messages.present?

    case corrected[:base_no]
    when 7,17
      key = corrected[:base_no]==7 ? :origin_date : :origin_date2
      # 休暇日と元日の重複チェック
      if corrected[:vacation_day] == corrected[:origin_date]
        alert_messages[key] = "「休暇日」と同じ日付が指定されています。"
      end

      # 振替元日の必須チェック
      if corrected[:origin_date].blank?
        alert_messages[key] = "必須項目です。"
      else
        # 振替元休暇の存在チェック
        case corrected[:base_no]
        when 7 # 振休
          if alert_messages.blank?
            origin_vacation = Vacation.unscoped.find_by(user_id: corrected[:user_id], vacation_day: corrected[:origin_date], base_no: 6)
            if origin_vacation.present?
              ck_result = origin_vacation.can_take_vacation(corrected[:vacation_day], corrected[:base_no], true, true)
              alert_messages[key] = ck_result[:msg] unless ck_result[:result]==200
            end
          end
        when 17 # 代休
          # 代休の場合は特別な処理が必要
          if alert_messages.blank?
            origin_vacation = Vacation.find_by(user_id: corrected[:user_id], vacation_day: corrected[:origin_date], base_no: 6, sts: 4)
            if origin_vacation.present?
              ck_result = origin_vacation.can_take_vacation(corrected[:vacation_day], corrected[:base_no], true, true)
              alert_messages[key] = ck_result[:msg] unless ck_result[:result]==200
            end
          end
        end
      end
    end
    alert_messages

  end

  def set_form_aleat(cc,alert_messages)
    alert_messages.each do |key,msg|
      cc.setparam(key.to_s,"msg",msg)
    end
  end

  def build_vacations(corrected,app_user)
    vacations = []
    user = User.find_by_id(corrected[:user_id])
    applecable = Applicable.get_applicable(2,corrected[:vacation_day])
    woker = Woker.find_by(:login_id=>user.login_id,:applicable=>applecable)
    return vacations if user.blank? || woker.blank?

    if corrected[:base_no] == 7
      origin_vacation = Vacation.unscoped.find_by(:user_id=>user.id,:vacation_day=>corrected[:origin_date],:base_no=>6)
      # origin_vacation = Vacation.find_by(:user_id=>user.id,:vacation_day=>corrected[:origin_date],:base_no=>6)
      if origin_vacation.present?
        corrected[:vacation_id] = origin_vacation.id
      end
    elsif corrected[:base_no] == 17
      origin_vacation = Vacation.find_by(:user_id=>user.id,:vacation_day=>corrected[:origin_date],:base_no=>6,:sts=>[4,5])
      if origin_vacation.present?
        corrected[:vacation_id] = origin_vacation.id
      end
    end

    corrected[:login_id] = user[:login_id]
    corrected[:branch_cd] = woker[:branch_cd]
    corrected[:sts] = 0
    corrected[:vacation_type_id] = VacationType.find_by(:base_no=>corrected[:base_no]).try(:id)
    corrected[:app_at] = Time.now
    corrected[:authorizer_id] = app_user[:id]
    corrected[:authorizer_name] = app_user[:name]
    corrected[:approval_at] = Time.now
    corrected[:created_at] = Time.now
    corrected[:created_uid] = app_user[:login_id]
    corrected[:updated_at] = Time.now
    corrected[:updated_uid] = app_user[:login_id]


    start_day = corrected[:vacation_day]
    end_day = corrected.delete(:vacation_end_day)
    end_day ||= start_day
    start_day.upto(end_day) do |wk_day|
      new_vacation = Vacation.new(corrected.merge(:vacation_day=>wk_day))
      new_vacation.auto_fill
      vacations << new_vacation
    end
    vacations
  end

  def delete_existing_vacations(vacations)
    user_id = vacations.first.user_id
    days = vacations.map(&:vacation_day)
    existing = Vacation.unscoped.where(:user_id=>user_id,:vacation_day=>days)
    if vacations.first.origin_date.present?
      origin = Vacation.unscoped.where(:user_id=>user_id,:origin_date=>vacations.first.origin_date,:base_no=>[7,17]).where.not(:id=>existing.pluck(:id))
      existing += origin if origin.present?
    end
    existing.each do |vacation|
      vacation.remove_and_restore_origin_vacation
    end
  end

  def regist_vacations(vacations)
    return if vacations.blank?
    vacations.each do |vacation|
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



  def build_result_message(vacations)
    msg = []
    if vacations.length ==1
      msg << "#{vacations.first[:vacation_day].strftime("%-m月%-d日")}の休暇を登録しました。"
    elsif vacations.length >=2
      msg << "#{vacations.first[:vacation_day].strftime("%-m月%-d日")}～#{vacations.last[:vacation_day].strftime("%-m月%-d日")}の休暇を登録しました。"
    end
    msg
  end





  def create_vacation_calendar_excel(t_year,t_month,t_branch_list)
    # 休暇カレンダーエクセルの作成
    require Rails.root.join("app/services/parser/vacation_calendar_excel_parser")

    yyyy = t_year.to_s.rjust(4,"0")
    mm = t_month.to_s.rjust(2,"0")
    t_tarm = get_month(Date.new(yyyy.to_i,mm.to_i,1))
    ow_branch_cd = t_branch_list
    
    # 最新バージョンの取得
    location = Excel::VacationCalendarExcel::OutputLocation

    file_name,last_version = Dir.glob("*_休暇カレンダー(#{yyyy}#{mm}_*).xls",base: location)\
    .map{|fn|
      match = fn.match(/\(\d+_(\d+)\)/)
      ver = match ? match[1].to_i : -1
      [fn,ver]
    }.sort_by{|_,ver| ver}&.last || []

    origin_excel_data = Formatter::VacationCalendarExcelFormatter::WorkBookTemplate
    if file_name.present?
      begin
        origin_excel_data = Parser::VacationCalendarExcelParser.new(location,file_name).parse()
      rescue IOError=> e
        Logger.new(STDOUT).warn "休暇カレンダーの読み込みに失敗しました。#{e.message}"
        flash[:error_msgs] = "休暇カレンダーの読み込みに失敗しました。"
        redirect_to :controller=>:home, :action=>:error; return
      end
    else
      last_version = 0
    end
    
    calendar = Vacation.load_calendar(t_tarm[:length][:begin_date],t_tarm[:length][:end_date])
    format_data = Formatter::VacationCalendarExcelFormatter.new(origin_excel_data,t_tarm,calendar,ow_branch_cd).fetch_data # {sheet_name: [[],[],[]]}
    excel = Excel::VacationCalendarExcel.new(format_data,"休暇カレンダー(#{yyyy}#{mm}_#{last_version.to_i+1})")
    excel.create()
    output = excel.fin
    return output
  end


end
