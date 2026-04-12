class Manager::HomeController < ApplicationController
  layout "main_layout"
  before_action :login_ck, :except => [:error]
  before_action :ck_manager, :except => [:error]
  
  #=== メニュー画面
  def menu
    @title="メニュー"
    #メニューデータの作成
    @linkdata = []
    links = []
    links << {:title=>"昼食集計",:link=>{:controller=>:lunch_orders}}
    links << {:title=>"掲示管理",:link=>{:controller=>:boards}}
    links << {:title=>"掲示閲覧",:link=>{:controller=>:o_boards,:action=>:index}}
    links << {:title=>"休暇管理",:link=>{:controller=>:vacations}}
    links << {:title=>"配番確定(実績登録)",:link=>{:controller=>:result_assignment,:t_date=>(Date.today-1).strftime("%Y%m%d")}}
    links << {:title=>"作業依頼",:link=>{:controller=>:cargo_requests}}
    links << {:title=>"荷役予定(必要人数設定)",:link=>{:controller=>:cargos}}
    links << {:title=>"配番",:link=>{:controller=>:wk_assignment}}
    @linkdata << [I18n.t("page_titles.admin",:name=>"業務メニュー"),links]
    links = []
    links << {:title=>"作業依頼書",:link=>"javascript:dlFile(document.f1,'SAGYO_REQUEST.PDF');"}
    links << {:title=>"必要人数表（調整用）",:link=>"javascript:dlFile(document.f1,'CARGO_REQUEST_HEAD_COUNT.PDF');"}
    links << {:title=>"配番人数表",:link=>"javascript:dlFile(document.f1,'CARGO_HEAD_COUNT.PDF');"}
    links << {:title=>"勤怠・時間外管理表",:link=>"javascript:dlFile(document.f1,'WOW.PDF');"}

    links << {:title=>"荷役作業員予定表",:link=>"javascript:dlFile(document.f1,'CARGO_WORKER_SCHEDULE.CSV');"}
    links << {:title=>"配番表(予定)",:link=>"javascript:dlFile(document.f1,'CARGO_SCHEDULE.PDF');"}
    links << {:title=>"出勤時間表",:link=>"javascript:dlFile(document.f1,'TIME_SHEET.PDF');"}
    links << {:title=>"出勤日報・残業届",:link=>"javascript:dlFile(document.f1,'WORK_DAILY_SHEET.PDF');"}
    
    links << {:title=>"タイムカードデータ",:link=>"javascript:dlFile(document.f1,'TIME_CARD.CSV');"}
    links << {}
    links << {}
    links << {}
    
    links << {:title=>"配番表(実績)",:link=>"javascript:dlFile(document.f2,'CARGO_RESULT.PDF');"}
    links << {:title=>"荷役実績(既存連携データ)",:link=>"javascript:dlFile(document.f2,'SAGYO_HAIBAN.CSV');"}
    links << {}
    links << {}

    @linkdata << [I18n.t("page_titles.admin",:name=>"随時帳票出力メニュー"),links]
    links = []
    links << {:title=>"日別荷役作業実績出力",:link=>"javascript:dlFile(document.f3,'DAILY_CARGO_WORK_RESULT.PDF');",:aggr_type=>"free"}
    links << {:title=>"荷役作業実績表出力",:link=>"javascript:dlFile(document.f3,'MONTHLY_CARGO_WORK_RESULT.PDF');",:aggr_type=>"free"}
    links << {:title=>"免税軽油稼働実績表出力",:link=>"javascript:dlFile(document.f3,'TAX_FREE_MACHINES_PDF');",:aggr_type=>"free"}
    links << {:title=>"荷役作業員実績表出力",:link=>"javascript:dlFile(document.f3,'CARGO_WORKER_RESULT.CSV');",:aggr_type=>"free"}
    links << {:title=>"昼食集計帳票出力",:link=>"javascript:dlFile(document.f3,'LUNCH_SUMMARY.EXCEL');",:aggr_type=>"free"}
    links << {:title=>"現業職労働時間・時間外管理表出力",:link=>"javascript:dlFile(document.f4,'WORK_TIME_SUMMARY.EXCEL');",:aggr_type=>"monthly"}
    links << {:title=>"荷役作業明細一覧出力",:link=>"javascript:dlFile(document.f3,'CARGO_WORK_DETAIL.EXCEL');",:aggr_type=>"free"}
    links << {:title=>"作業員毎作業一覧出力",:link=>"javascript:dlFile(document.f3,'WORKER_WORK_SUMMARY.EXCEL');",:aggr_type=>"free"}
    links << {:title=>"休暇カレンダー出力",:link=>"javascript:dlFile(document.f4,'VACATION_CALENDAR.EXCEL');",:aggr_type=>"monthly"}

    #links << {:title=>"昼食集計帳票出力",:link=>{:controller=>:lunch_summary,:action=>:index}}
    @linkdata << [I18n.t("page_titles.admin",:name=>"集計・帳票出力メニュー"),links]

    links = []
    links << {:title=>I18n.t("activerecord.models.wh_calendar"),:link=>{:controller=>:wh_calendars}}
    links << {:title=>I18n.t("activerecord.models.vacation_type"),:link=>{:controller=>:vacation_types}}
    links << {:title=>I18n.t("activerecord.models.applicable"),:link=>{:controller=>:applicables}}
    links << {:title=>I18n.t("activerecord.models.branche"),:link=>{:controller=>:branches}}

    links << {:title=>I18n.t("activerecord.models.user"),:link=>{:controller=>:users}}
    links << {:title=>I18n.t("activerecord.models.user_auth"),:link=>{:controller=>:user_auths}}
    links << {:title=>I18n.t("activerecord.models.woker"),:link=>{:controller=>:wokers}}
    links << {}

    links << {:title=>I18n.t("activerecord.models.machine"),:link=>{:controller=>:machines}}
    links << {:title=>I18n.t("activerecord.models.machine_maintenance"),:link=>{:controller=>:machine_maintenances}}
    links << {}
    links << {}

    links << {:title=>I18n.t("activerecord.models.cargo_class_master"),:link=>{:controller=>:cargo_class_masters}}
    links << {:title=>I18n.t("activerecord.models.cargo_cd_master"),:link=>{:controller=>:cargo_cd_masters}}
    links << {:title=>I18n.t("activerecord.models.cargo_master"),:link=>{:controller=>:cargo_masters}}
    links << {}

    links << {:title=>I18n.t("activerecord.models.lunch_vendor"),:link=>{:controller=>:lunch_vendors}}
    links << {:title=>I18n.t("activerecord.models.lunch_menu"),:link=>{:controller=>:lunch_menus}}
    links << {:title=>I18n.t("activerecord.models.lunch_location"),:link=>{:controller=>:lunch_locations}}
    links << {}

    links << {:title=>I18n.t("activerecord.models.board_category"),:link=>{:controller=>:board_categories}}
    links << {:title=>I18n.t("activerecord.models.board_group"),:link=>{:controller=>:board_groups}}
    links << {}
    links << {}
    
    @linkdata << [I18n.t("page_titles.admin",:name=>"マスタ"),links]
    if is_admin?
      links = []
      links << {:title=>"JOBエラークリア",:link=>{:action=>:destroy_job_err}}
      links << {:title=>"不足休割当て",:link=>{:controller=>:vacations,:action=>:test_run,:mord=>"add6"}}
      links << {:title=>"休暇リセット(法定休除く)",:link=>{:controller=>:vacations,:action=>:test_run,:mord=>"reset6"}}
      links << {:title=>"終業時間計算テスト",:link=>{:action=>:test_calc_work_time}}
      #links << {:title=>"テスト用休暇日登録",:link=>{:action=>:mk_test_vacation}}
      #links << {:title=>"テスト用昼食注文登録",:link=>{:action=>:mk_test_lunch_order}}
      @linkdata << ["開発機能",links]
    end
    #検索データの削除
    session[:serch_data] = {}
    session[:page_data] = {}
    session[:back_link] = nil
    session[:t_date] = nil

    @current_monthly = get_month(Date.today)

  end

  #=== エラー画面
  def error
  end
  # Jobのエラーを削除
  def destroy_job_err
    DelayedJob.where("last_error<>''").destroy_all
    flash[:error_msgs] = "エラーのJOBを削除しました。"
    redirect_to :action=>:menu
  end
  # テスト用休暇日登録
  def mk_test_vacation
    Vacation.mk_test_vacation(get_month)
    flash[:error_msgs] = "休暇申請をランダムに作成しました。"
    redirect_to :action=>:menu
  end
  # テスト用昼食注文登録
  def mk_test_lunch_order
    ret = LunchOrder.mk_test_order(get_month)
    #flash[:error_msgs] = "休暇申請をランダムに作成しました。"
    #redirect_to :action=>:menu
    render :json => ret.to_json, :status => 200
  end

  #--
  ######################################################
  #管理画面共通
  ######################################################
  #++

  #=== 管理共通（一覧画面表示）
  def index
    @title = I18n.t("page_titles.index",:name=>@my_setting[:table].model_name.human)
    @cc = @my_setting[:table].set_list_form(@my_setting[:table].model_name.name)
    cc_adjustment if self.private_methods.include?(:cc_adjustment)
    @ss = Common::CommonClass.new(@cc.getgname)
    @ss.set_serch_params(@cc)
    @ss.setpostdata(params,session[:serch_data])
    sql_where = @ss.mksqlwhere(@my_setting[:def_where])
    strselect=@cc.mksqlselect()
    @datas = @my_setting[:table].get_list(get_page(params,@cc),strselect,sql_where,@my_setting[:order])
  end
  #=== 管理共通（新規登録画面表示）
  def new
    @title = I18n.t("page_titles.new",:name=>@my_setting[:table].model_name.human)
    @cc = @my_setting[:table].set_input_form("#{@my_setting[:table].model_name.name}_in")
    cc_adjustment if self.private_methods.include?(:cc_adjustment)
  end
  #=== 管理共通（新規登録処理）
  def create
    @title = I18n.t("page_titles.new",:name=>@my_setting[:table].model_name.human)
    @cc = @my_setting[:table].set_input_form("#{@my_setting[:table].model_name.name}_in")
    cc_adjustment if self.private_methods.include?(:cc_adjustment)
    if @cc.setpostdata(params)
      begin
        @my_setting[:table].transaction do
          datas = @cc.mksqldata(session[UserSessionKey][:login_id])
          datas.merge!(@my_setting[:merge_data]) if @my_setting[:merge_data].present?
          @dataline = @my_setting[:table].create_data(@my_setting[:table_keys],
            datas,session[UserSessionKey][:login_id],false,true)
          @my_setting[:file_keys].each{|key|
            file_nm = "#{key}_#{@dataline[:id]}"
          @cc.save_file(key,file_nm,params["#{key}_delck"])
          }unless @my_setting[:file_keys].blank?
          if @dataline[@my_setting[:msg_key]].blank?
            flash[:msg] = I18n.t("system_messages.create_b")
          else
            flash[:msg] = I18n.t("system_messages.create",:name=>@dataline[@my_setting[:msg_key]])
          end
        end
        redirect_to :action=>:index
        return
      rescue DuplicationError
        set_error("system_alert.allrady_exists",nil,true,
          {:name=>@cc.getparamdata(@my_setting[:table_keys],"title"),:val=>@cc.getparamdata(@my_setting[:table_keys],"v_value")})
      rescue
        set_error("system_errors.update")
        redirect_to :controller =>:home,:action=>:error
        return
      end
    end
    render :action => :new
  end
  #=== 管理共通（変更登録画面表示）
  def edit
    @title = I18n.t("page_titles.edit",:name=>@my_setting[:table].model_name.human)
    @cc = @my_setting[:table].set_edit_form("#{@my_setting[:table].model_name.name}_in")
    cc_adjustment if self.private_methods.include?(:cc_adjustment)
    begin
      @dataline = @my_setting[:table].find(params[:id])
    rescue ActiveRecord::RecordNotFound
      set_error("system_errors.page_link")
      redirect_to :controller =>:home,:action=>:error
      return
    end
    @cc.setdbdata(@dataline)
  end

  #=== 管理共通（変更登録処理）
  def update
    @title = I18n.t("page_titles.edit",:name=>@my_setting[:table].model_name.human)
    @cc = @my_setting[:table].set_edit_form("#{@my_setting[:table].model_name.name}_in")
    
    cc_adjustment if self.private_methods.include?(:cc_adjustment)
    if @cc.setpostdata(params)
      begin

        @my_setting[:table].transaction do
          datas = @cc.mksqldata(session[UserSessionKey][:login_id])
          @dataline = @my_setting[:table].find(params[:id])
          @my_setting[:file_keys].each{|key|
            datas.delete(key) if params["#{key}_delck"].nil? && @cc.getparamdata(key,'value').blank?
          }unless @my_setting[:file_keys].blank?
          @dataline.update(datas)
          @my_setting[:file_keys].each{|key|
            file_nm = "#{key}_#{@dataline[:id]}"
          @cc.save_file(key,file_nm,params["#{key}_delck"])
          }unless @my_setting[:file_keys].blank?
          if @dataline[@my_setting[:msg_key]].blank?
            flash[:msg] = I18n.t("system_messages.update_b")
          else
            flash[:msg] = I18n.t("system_messages.update",:name=>@dataline[@my_setting[:msg_key]])
          end
        end

        redirect_to session[:back_to].blank? ? {:action=>:index} : session[:back_to]
        session[:back_to] = nil
        return
      rescue ActiveRecord::RecordNotUnique
        set_error("system_alert.allrady_exists",nil,true,
          {:name=>@cc.getparamdata(@my_setting[:table_keys],"title"),:val=>@cc.getparamdata(@my_setting[:table_keys],"v_value")})
      rescue
        set_error("system_errors.update")
        redirect_to :controller =>:home,:action=>:error
        return
      end
    end

    render :action => :edit
  end

  #=== 管理共通（削除処理）
  def destroy
    begin
      @my_setting[:table].transaction do
        dataline = @my_setting[:table].find(params[:id])
        dataline.update({
          :deleted_uid => session[UserSessionKey][:login_id],
          :deleted_at => Time.now()
          })
        if dataline[@my_setting[:msg_key]].blank?
          flash[:msg] = I18n.t("system_messages.destroy_b")
        else
          flash[:msg] = I18n.t("system_messages.destroy",:name=>dataline[@my_setting[:msg_key]])
        end
      end
      redirect_to :action=>:index
    rescue
      set_error("system_errors.update")
      redirect_to :controller =>:home,:action=>:error
    end
    return
  end
  #=== 管理共通（CSV一括登録画面表示）
  def csv_in
    @title = I18n.t("page_titles.csv_in",:name=>@my_setting[:table].model_name.human)
    @out_file_name = I18n.t("page_titles.index",:name=>@my_setting[:table].model_name.human)
    @cc = @my_setting[:table].set_csv_form("#{@my_setting[:table].model_name.name}_csv")
    cc_adjustment if self.private_methods.include?(:cc_adjustment)
  end
  #=== 管理共通（CSVエクスポート）
  def csv_output
    require 'kconv'
    require 'csv'
    file_name = I18n.t("page_titles.index",:name=>@my_setting[:table].model_name.human)
    @cc = @my_setting[:table].set_csv_form("#{@my_setting[:table].model_name.name}_csv")
    cc_adjustment if self.private_methods.include?(:cc_adjustment)
    datas = @my_setting[:table].where(@my_setting[:def_where]).order(@my_setting[:order])
    output = @cc.mk_csv_data(datas)
    send_data(output.join("").kconv(Encoding::CP932,Kconv::UTF8), :type => csv_content_type(),
      :filename => "#{file_name}.csv",:disposition=>'attachment')
  end
  #=== 管理共通（CSVインポート）
  def csv_input
    @title = I18n.t("page_titles.csv_in",:name=>@my_setting[:table].model_name.human)
    @out_file_name = I18n.t("page_titles.index",:name=>@my_setting[:table].model_name.human)
    @cc = @my_setting[:table].set_csv_form("#{@my_setting[:table].model_name.name}_csv")
    cc_adjustment if self.private_methods.include?(:cc_adjustment)
    unless params[:file].nil?
      fobj = params[:file][:csv]
      ret = {}
      begin
        @my_setting[:table].transaction do
          ret = @cc.uplode_csv_data(fobj,@my_setting[:table],@my_setting[:table_keys],session[UserSessionKey][:login_id])
        end
        if ret[:cd]
          if ret[:counts][:I] == 0 and ret[:counts][:U] == 0
            set_error("system_alert.not_fund",nil,true)
          else
            flash.now[:msgs] = I18n.t("system_messages.csv_end",
              **{ :i=> (ret[:counts][:I] > 0 ? I18n.t("system_messages.csv_i",:count=>ret[:counts][:I]) : nil),
                :u=> (ret[:counts][:U] > 0 ? I18n.t("system_messages.csv_u",:count=>ret[:counts][:U]) : nil),
              })
          end
        else
          flash.now[:error_msgs] = ret[:msg]
        end
      rescue CSV::MalformedCSVError
        set_error("system_errors.csv_parse",nil,true)
      rescue
        set_error("system_errors.exception")
        redirect_to :controller =>:home,:action=>:error
        return
      end
    end
    render :action=> :csv_in
  end
  #=== 管理共通（詳細画面表示）
  def show
    dataline = @my_setting[:table].find(params[:id])
    ret = {}
    dataline.attribute_names.each{|key|
      case key
      when "id","lock_version","created_at","created_uid","updated_at","updated_uid","deleted_at","deleted_uid"
        #スキップ
      else
        ret[key] = dataline[key]
      end
    } unless dataline.blank?
    ret[:info_str] = dataline.try(:info_str)
    render :json => ret.to_json, :status => 200
  end
  #==================================================#
  def test_calc_work_time
    tm = Proc.new{|hhmm| Time.parse("2000-01-01 #{hhmm}")}
    test_data = [
      ['07:00','16:00',60,0,0],
      ['07:00','16:30',90,0,0],
      ['07:00','17:00',120,30,30],
      ['07:00','17:30',150,60,60],
      ['07:00','18:00',180,90,90],
      ['07:00','18:30',210,120,120],
      ['07:00','19:00',240,120,120],
      ['07:00','19:30',270,150,150],
      ['07:00','20:00',300,180,180],
      ['07:00','20:30',330,210,180],
      ['07:00','21:00',360,210,210],
      ['07:00','21:30',390,240,210],
      ['07:00','22:00',420,270,240],
      ['07:30','16:00',30,0,0],
      ['07:30','16:30',60,0,0],
      ['07:30','17:00',90,0,0],
      ['07:30','17:30',120,30,30],
      ['07:30','18:00',150,60,60],
      ['07:30','18:30',180,90,90],
      ['07:30','19:00',210,90,90],
      ['07:30','19:30',240,120,120],
      ['07:30','20:00',270,150,150],
      ['07:30','20:30',300,180,180],
      ['07:30','21:00',330,180,180],
      ['07:30','21:30',360,210,210],
      ['07:30','22:00',390,240,240],
      ['08:00','16:00',0,0,0],
      ['08:00','16:30',30,0,0],
      ['08:00','17:00',60,0,0],
      ['08:00','17:30',90,0,0],
      ['08:00','18:00',120,30,30],
      ['08:00','18:30',150,60,60],
      ['08:00','19:00',180,60,60],
      ['08:00','19:30',210,90,90],
      ['08:00','20:00',240,120,120],
      ['08:00','20:30',270,150,150],
      ['08:00','21:00',300,150,150],
      ['08:00','21:30',330,180,180],
      ['08:00','22:00',360,210,210],
    ]

    alerts = []
    test_data.each.with_index {|var,index|
      p "";p "";p "-- #{index}回目のテストを実行 --"
      s,e,ex_p_orver_time,ex_orver_time,ex_orver_time_bus = var
      common = "不一致発生(開始：#{s}　終了：#{e})        "

      #-- Variables
      work_date = Date.new(2025,6,26)
      s_time = tm.call(s)
      e_time = tm.call(e)

      p " > テスト条件 < "
      p "開始 : #{s}    終了 : #{e}"
	
      #-- Calc work time
      p_work_time = WorkTimeAggregate.calc_prescribed_work_time(work_date,s_time,e_time)
      work_time = WorkTimeAggregate.calc_legal_work_time(work_date,s_time,e_time,false)
      work_time_bus = WorkTimeAggregate.calc_legal_work_time(work_date,s_time,e_time,true)
      
      #-- Build result message
      # calc_result = []
      # calc_result << "所定時間外 : #{p_work_time[1..2].sum}min"
      # calc_result << "法定時間外 : #{work_time[1]}min"
      # calc_result << "法定時間外(バス手当あり) : #{work_time_bus[1]}min"
      # calc_result
      
      unmatch = [0,0,0]

      if ex_p_orver_time != p_work_time[1..2].sum
        msg = common + "所定時間外                 期待する値：#{ex_p_orver_time.to_s.rjust(7)}        計算結果：#{p_work_time[1..2].sum.to_s.rjust(7)}    差：#{(ex_p_orver_time - p_work_time[1..2].sum) * -1}min"
        alerts << [0,msg]
        unmatch[0] = true
      end
      if ex_orver_time != work_time[1]
        msg = common + "法定時間外                 期待する値：#{ex_orver_time.to_s.rjust(7)}        計算結果：#{work_time[1].to_s.rjust(7)}    差：#{(ex_orver_time - work_time[1]) * -1}min"
        alerts << [1,msg]
        unmatch[1] = true
      end
      if ex_orver_time_bus != work_time_bus[1]
        msg = common + "法定時間外(バス手当あり)   期待する値：#{ex_orver_time_bus.to_s.rjust(7)}        計算結果：#{work_time_bus[1].to_s.rjust(7)}    差：#{(ex_orver_time_bus - work_time_bus[1]) * -1}min"
        alerts << [2,msg] 
        unmatch[2] = true
      end

      if false && unmatch.any?{|r| r == true}
        if unmatch[0]
          binding.break
          WorkTimeAggregate.calc_prescribed_work_time(work_date,s_time,e_time)
        end
        if unmatch[1]
          binding.break
          WorkTimeAggregate.calc_legal_work_time(work_date,s_time,e_time,false)
        end
        if unmatch[2]
          binding.break
          WorkTimeAggregate.calc_legal_work_time(work_date,s_time,e_time,true)
        end
      end
    }

    render :json =>alerts.sort_by{|num,msg| num}.map{|num,msg| msg}.to_json, :status => 200
  end
  private

end
