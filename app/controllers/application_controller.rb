class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception, :with => :render_500
    rescue_from ActiveRecord::RecordNotFound,  :with => :render_404
    rescue_from ActionController::RoutingError,  :with => :render_404
  end
  
  #--
  ###############################################################
  #=共通画面
  ###############################################################
  #++
  # 共通画面（４０４）
  def render_404(exception = nil)
    logger.info "Rendering 404 with exception: #{exception.message}" if exception
    @title = "エラー"
    flash.now[:error_msgs] = "#{I18n.t("system_errors.page_link")}<br />#{exception.try(:message)}"
    respond_to{|format|
      format.any
      format.html {render :action=>:exception,:layout=>"main_layout", content_type: 'text/html',:status=>404}
    }
  end
  # 共通画面（５００）
  def render_500(exception = nil)
    if exception.present?
      logger.error "Rendering 500 with exception: #{exception.message}"  
      logger.error exception.backtrace.join("\n")
      ExceptionNotifier.notify_exception(exception)
    end
    @title = "エラー"
    flash.now[:error_msgs] = "#{I18n.t("system_errors.exception")}<br />#{exception.try(:message)}"
    render :template=>"/application/exception",:layout=>"main_layout",:status=>500
  end
  
  # メニュー画面に表示するメニューリストを取得
  # 引数ユーザの権限による
  def get_menu_list(login_user_id)
    user = User.find(login_user_id)
    uo = params[:user_auth] || UserAuth.find_by_login_id(user.login_id)
    manager_flg = is_manager?
    def_branch_cd = Woker.find_by({:applicable=>Applicable.get_applicable(2,@t_date),:login_id=>get_uval(:login_id)})


    menu_list = []
    return menu_list if is_operator?

    #メニューデータの作成
    links = []
    links << {:title=>"昼食集計",:link=>{:controller=>:lunch_orders}} if manager_flg || uo.lunch_orders==1
    links << {:title=>"掲示管理",:link=>{:controller=>:m_boards}} if manager_flg || uo.boards==1
    links << {:title=>"休暇管理",:link=>{:controller=>:vacations,:action=>:index,:def_branch_cd=>def_branch_cd&.branch_cd}} if manager_flg || uo.vacations==1
    links << {:title=>"配番確定(実績登録)",:link=>{:controller=>:result_assignment,:t_date=>(Date.today-1).strftime("%Y%m%d")}} if manager_flg || uo.result_assignment==1
    links << {:title=>"作業依頼",:link=>{:controller=>:cargo_requests}} if manager_flg || uo.cargo_requests==1
    links << {:title=>"荷役予定(必要人数設定)",:link=>{:controller=>:cargos}} if manager_flg || uo.cargos==1
    links << {:title=>"配番",:link=>{:controller=>:wk_assignment}} if manager_flg || uo.wk_assignment==1
    (4-links.length%4).times {links << {}}
    menu_list << [I18n.t("page_titles.admin",:name=>"業務メニュー"),links]

    links = []
    links << {:title=>"作業依頼書",:link=>"javascript:dlFile(document.f1,'SAGYO_REQUEST.PDF');"} if manager_flg || uo.sagyo_request==1
    links << {:title=>"必要人数表（調整用）",:link=>"javascript:dlFile(document.f1,'CARGO_REQUEST_HEAD_COUNT.PDF');"} if manager_flg || uo.cargo_request_head_count==1
    links << {:title=>"配番人数表",:link=>"javascript:dlFile(document.f1,'CARGO_HEAD_COUNT.PDF');"} if manager_flg || uo.cargo_head_count==1
    links << {:title=>"勤怠・時間外管理表",:link=>"javascript:dlFile(document.f1,'WOW.PDF');"} if manager_flg || uo.p_orver_time_sheet==1
    links << {:title=>"荷役作業員予定表",:link=>"javascript:dlFile(document.f1,'CARGO_WORKER_SCHEDULE.CSV');"} if manager_flg || uo.cargo_worker_schedule==1
    links << {:title=>"配番表(予定)",:link=>"javascript:dlFile(document.f1,'CARGO_SCHEDULE.PDF');"} if manager_flg || uo.cargo_schedule==1
    links << {:title=>"出勤時間表",:link=>"javascript:dlFile(document.f1,'TIME_SHEET.PDF');"} if manager_flg || uo.time_sheet==1
    links << {:title=>"出勤日報・残業届",:link=>"javascript:dlFile(document.f1,'WORK_DAILY_SHEET.PDF');"} if manager_flg || uo.work_daily_sheet==1
    links << {:title=>"タイムカードデータ",:link=>"javascript:dlFile(document.f1,'TIME_CARD.CSV');"} if manager_flg || uo.time_card==1
    links << {:title=>"配番表(実績)",:link=>"javascript:dlFile(document.f2,'CARGO_RESULT.PDF');"} if manager_flg || uo.cargo_result==1
    links << {:title=>"荷役実績(既存連携データ)",:link=>"javascript:dlFile(document.f2,'SAGYO_HAIBAN.CSV');"} if manager_flg || uo.sagyo_haiban==1
    (4-links.length%4).times {links << {}}
    menu_list << [I18n.t("page_titles.admin",:name=>"随時帳票出力メニュー"),links]

    links = []
    links << {:title=>"日別荷役作業実績出力",:link=>"javascript:dlFile(document.f3,'DAILY_CARGO_WORK_RESULT.PDF');",:aggr_type=>"free"}  if manager_flg || uo.daily_cargo_work_result==1
    links << {:title=>"荷役作業実績表出力",:link=>"javascript:dlFile(document.f3,'MONTHLY_CARGO_WORK_RESULT.PDF');",:aggr_type=>"free"} if manager_flg || uo.monthly_cargo_work_result==1
    links << {:title=>"免税軽油稼働実績表出力",:link=>"javascript:dlFile(document.f3,'TAX_FREE_MACHINES_PDF');",:aggr_type=>"free"} if manager_flg || uo.tax_free_machines_pdf==1
    links << {:title=>"荷役作業員実績表出力",:link=>"javascript:dlFile(document.f3,'CARGO_WORKER_RESULT.CSV');",:aggr_type=>"free"} if manager_flg || uo.cargo_worker_result==1
    links << {:title=>"昼食集計帳票出力",:link=>"javascript:dlFile(document.f3,'LUNCH_SUMMARY.EXCEL');",:aggr_type=>"free"} if manager_flg || uo.lunch_summary==1
    links << {:title=>"現業職労働時間・時間外管理表出力",:link=>"javascript:dlFile(document.f4,'WORK_TIME_SUMMARY.EXCEL');",:aggr_type=>"monthly"} if manager_flg || uo.work_time_summary==1
    links << {:title=>"荷役作業明細一覧出力",:link=>"javascript:dlFile(document.f3,'CARGO_WORK_DETAIL.EXCEL');",:aggr_type=>"free"} if manager_flg || uo.cargo_work_detail==1
    links << {:title=>"作業員毎作業一覧出力",:link=>"javascript:dlFile(document.f3,'WORKER_WORK_SUMMARY.EXCEL');",:aggr_type=>"free"} if manager_flg || uo.worker_work_summary==1
    links << {:title=>"休暇カレンダー出力",:link=>"javascript:dlFile(document.f4,'VACATION_CALENDAR.EXCEL');",:aggr_type=>"monthly"} if manager_flg || uo.vacations==1
    
    menu_list << [I18n.t("page_titles.admin",:name=>"集計・帳票出力メニュー"),links]

    links = []
    links << {:title=>I18n.t("activerecord.models.wh_calendar"),:link=>{:controller=>:wh_calendars}} if manager_flg
    links << {:title=>I18n.t("activerecord.models.vacation_type"),:link=>{:controller=>:vacation_types}} if manager_flg
    links << {:title=>I18n.t("activerecord.models.applicable"),:link=>{:controller=>:applicables}} if manager_flg
    links << {:title=>I18n.t("activerecord.models.branche"),:link=>{:controller=>:branches}} if manager_flg
    links << {:title=>I18n.t("activerecord.models.user"),:link=>{:controller=>:users}} if manager_flg
    links << {:title=>I18n.t("activerecord.models.user_auth"),:link=>{:controller=>:user_auths}} if manager_flg
    links << {:title=>I18n.t("activerecord.models.woker"),:link=>{:controller=>:wokers}} if manager_flg
    links << {:title=>I18n.t("activerecord.models.machine"),:link=>{:controller=>:machines}} if manager_flg
    links << {:title=>I18n.t("activerecord.models.machine_maintenance"),:link=>{:controller=>:machine_maintenances}} if manager_flg
    links << {:title=>I18n.t("activerecord.models.cargo_class_master"),:link=>{:controller=>:cargo_class_masters}} if manager_flg
    links << {:title=>I18n.t("activerecord.models.cargo_cd_master"),:link=>{:controller=>:cargo_cd_masters}} if manager_flg
    links << {:title=>I18n.t("activerecord.models.cargo_master"),:link=>{:controller=>:cargo_masters}} if manager_flg
    links << {:title=>I18n.t("activerecord.models.lunch_vendor"),:link=>{:controller=>:lunch_vendors}} if manager_flg
    links << {:title=>I18n.t("activerecord.models.lunch_menu"),:link=>{:controller=>:lunch_menus}} if manager_flg
    links << {:title=>I18n.t("activerecord.models.lunch_location"),:link=>{:controller=>:lunch_locations}} if manager_flg
    links << {:title=>I18n.t("activerecord.models.board_category"),:link=>{:controller=>:board_categories}} if manager_flg
    links << {:title=>I18n.t("activerecord.models.board_group"),:link=>{:controller=>:board_groups}} if manager_flg
    (4-links.length%4).times {links << {}}
    
    links = []
    links << {:title=>"パスワード変更",:link=>{:controller=>:users,:action=>:edit,:target=>'password'}}
    links << {:title=>"パスワードリマインド質問変更",:link=>{:controller=>:users,:action=>:edit,:target=>'setting'}}
    (4-links.length%4).times {links << {}}
    menu_list << [I18n.t("page_titles.admin",:name=>"ユーザ設定"),links]


    menu_list

  end
  
  
  
  ###############################################################
  #共通関数
  ###############################################################
  private
  #
  #====ページ番号の取得
  def get_page(params,cc)
    return 1 if (params.nil? || cc.nil?)
    session[:page_data] ||= {}
    if params[:page].blank?
      gname = cc.getgname
      if params[gname].nil?
        return session[:page_data][gname]
      else
        session[:page_data][gname] = 1
        return 1
      end
    else
      session[:page_data][cc.getgname] = params[:page]
      return params[:page]
    end
  end
  #
  #====エラーメッセージ、ログをSet
  def set_error(error_no, e = $! , now = false ,replace = {},is_user=false)
    f = (now ? flash.now : flash)
    f[:error_no] = error_no
    f[:error_msgs] ||= []
    msg = I18n.t(error_no,**replace)
    # msg = I18n.t(error_no)
    unless msg.blank?
      f[:error_msgs] << msg
    end
    if !e.nil? && !e.backtrace.blank?
      f[:error_msgs] << e.to_s unless is_user
      strlog = "-----\n"
      strlog << "error_no:#{error_no}\n"
      strlog << "error_msg:#{e.to_s}\n"
      strlog << "backtrace\n"
      strlog << e.backtrace.join("\n")
      logger.error(strlog)
    end
  end

  # =CSVのcontent-typeを返します。
  # Author  :: EC-One ValiTech arima
  def csv_content_type
    if request.user_agent =~ /windows/i then
      #クライアント環境がWindowsの場合はExcel形式で返す
      "application/vnd.ms-excel"
    else
      #それ以外の場合にはCSV形式で返す
      "text/csv"
    end
  end
  #
  #====指定キー以外のセッションデータをクリア
  def session_clear(ikeys = [])
    tmp = {}
    ikeys.each{|key|
      tmp[key] = Marshal.load(Marshal.dump(session[key]))
    }unless ikeys.blank?
    reset_session
    ikeys.each{|key| session[key] = tmp[key] }unless ikeys.blank?
  end
  #
  #====自画面以外の検索データをクリア
  def serch_data_clear(gname)
    unless session[:serch_data].blank?
      session[:serch_data].each_key do |key|
        session[:serch_data].delete(key)  unless key == gname
      end
    end
  end
  #
  #====接続元IPチェック
  def check_ip
    unless ENV[ALLOW_IP_ENV_KEY].nil?
      ip_check = false
      remote_ip = request.env["HTTP_X_FORWARDED_FOR"] || request.remote_ip
      ENV[ALLOW_IP_ENV_KEY].split(/\s*,\s*/).each{|allow_ip_str|
        case allow_ip_str
        when /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})-(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})$/
          ip_check = ip_check || ip_match(remote_ip,$1,$2)
        when /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})$/
          ip_check = ip_check || ip_match(remote_ip,$1)
        else
          ip_check = ip_check || (remote_ip == allow_ip_str)
        end
        break if ip_check
      }
      unless ip_check
        @title = "エラー"
        flash.now[:error_msgs] = [I18n.t("system_errors.ip"),"#{remote_ip}"]
        render :template=>"application/exception",:layout=>"main_layout"
        return
      end
    end
  end
  #
  #=== IPアドレスチェック
  def ip_match(r_ip,ck_ip1,ck_ip2 = nil)
    ret = false
    if r_ip =~ /\s*,\s*/
      r_ip.split(/\s*,\s*/).each{|rip|
      ret = ret || ip_match(rip,ck_ip1,ck_ip2)
    }
    elsif ck_ip2.nil?
      ret = (r_ip == ck_ip1)
    else
      i = (r_ip.split(/\s*\.\s*/).map {|c| c.to_i}).each
      s = (ck_ip1.split(/\s*\.\s*/).map {|c| c.to_i}).each
      e = (ck_ip2.split(/\s*\.\s*/).map {|c| c.to_i}).each
      ret_s = true
      ret_e = true
      loop{
        ii = i.next
        ss = s.next
        ee = e.next
        ret_s = ret_s && (ii >= ss)
        ret_e = ret_e && (ii <= ee)
        break unless (ret_s && ret_e)
      }
      ret = ret_s && ret_e
    end
    return ret
  end
  #====Session内のユーザデータを取得
  def get_uval(key)
    return session[UserSessionKey][key] unless session[UserSessionKey].nil?
    return nil
  end
  #====ログインチェック
  #引数::なし
  #対象セッションが無い場合エラー画面にリダイレクト
  def login_ck
    if get_uval(:login_id).nil?
      set_error("system_errors.session")
      redirect_to :controller =>"/login",:action=>:login
      return
    end
  end
  #====管理者か？
  def is_admin?
    return (get_uval(:auth_flg) == 5)
  end
  #====管理課か？
  def is_manager?
    return is_admin? || (get_uval(:auth_flg) == 4)
  end
  def ck_manager
    unless is_manager?
      set_error("system_errors.page_link")
      redirect_to :controller=>:home ,:action => :error
      return
    end
  end
  #====親方か？
  def is_bos?
    return (get_uval(:auth_flg) == 3)
  end
  def ck_bos
    unless is_bos?
      set_error("system_errors.page_link")
      redirect_to :controller=>:home ,:action => :error
      return
    end
  end
  #====事務職か？
  def is_officeworker?
    return [1,2].include?(get_uval(:auth_flg))
  end
  def ck_officeworker
    unless is_officeworker?
      set_error("system_errors.page_link")
      redirect_to :controller=>:home ,:action => :error
      return
    end
  end
  #====現場職か？
  def is_operator?
    return (get_uval(:auth_flg) == 0)
  end
  def ck_operator
    unless is_operator?
      set_error("system_errors.page_link")
      redirect_to :controller=>:home ,:action => :error
      return
    end
  end

  
  #
  #=== 表示対象日付取得
  def get_set_tdate 
    if params[:t_date].blank? && session[:t_date].blank?
      session[:t_date] = Date.today.strftime("%Y%m%d")
    elsif params[:t_date].present? && params[:t_date] =~ /\d{8}/
      session[:t_date] = params[:t_date]
    end
    @t_date = Date.strptime(session[:t_date], "%Y%m%d")
  end
  
  #=== 表示対象日付取得
    # 関数名 : get_month
    # 説明 : t_dateの営業月と日付範囲を返す
    # 引数 :  
    #   t_date:date型 -> 問合日
    #   [month_offset:int型 -> 問合日の〇〇カ月後]
    # 使い方 :  
    #   $ get_month(Date.parse("2023-12-15")) 
    #     ====> {year:2023 ,month: 12, length: {begin_date: '2023-11-16', end_date: '2023-12-15'}}
    #   $ get_month(Date.parse("2023-12-16")) 
    #     ====> {year:2024 ,month: 1, length: {begin_date: '2023-12-16', end_date: '2024-1-15'}}
    #   $ get_month(Date.parse("2024-1-15")) 
    #     ====> {year:2024 ,month: 1, length: {begin_date: '2023-12-16', end_date: '2024-1-15'}}
    #   $ get_month(Date.parse("2024-1-16")) 
    #     ====> {year:2024 ,month: 2, length: {begin_date: '2024-1-16', end_date: '2024-2-15'}}
    #   $ get_month(Date.parse("2024-1-16"),1) 
    #     ====> {month: 3, length: {begin_date: '2024-2-16', end_date: '2024-3-15'}}
  def get_month(t_date=Date.today,month_offset = 0)
    def over_switch_date?(day_)
      switch_date = 15
      day_ > switch_date
    end
    d = t_date.next_month(month_offset)
    d = over_switch_date?(d.day) ? d : d.prev_month
    begin_date = Date.new(d.year,d.month,15 +1)
    d = d.next_month(1)
    end_date = Date.new(d.year,d.month,15)
    year = end_date.year
    month = end_date.month
    return {year: year,month: month,length: {begin_date: begin_date,end_date: end_date}}
  end


  def menu_all()
  end


end
