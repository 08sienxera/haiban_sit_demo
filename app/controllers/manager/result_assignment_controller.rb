class Manager::ResultAssignmentController < Manager::HomeController
  layout "main_layout"
  before_action :get_set_tdate
  before_action :set_my_global_variable

  #=== 配番確定(実績登録)画面を表示
  def index
    @title="配番確定(実績登録)"
    @cargo = ResultCargo.where({:work_date=>@t_date[:t_date]}).order(:desp_index).includes([:result_cargo_worker,:result_cargo_machine])
    
    #配番ユーザデータ取得
    this_mm = get_month(@t_date[:t_date])
    @branches = Branche.get_assignment_list(@t_date[:t_date])
    @wokers,@woker_names = Woker.get_assignment_list(@t_date,@branches,this_mm)
    #休暇種別
    @vacation_types = {"0"=>"公休日"}.merge(VacationType.getdatalist({:key=>:base_no,:text=>:name,:type=>"hash"}))
    #配番機械データ取得
    @machines,@machine_names,@machine_bgc_class = Machine.get_assignment_list(@t_date[:t_date])
    #言付けデータ取得
    @msgs = CargoMsg.get_assignment_list(@t_date[:t_date])
    
    #表示設定
    @inc_css = [:wk_assignment]
    @inc_js= ["manager/commn_assignment","manager/result_assignment","manager/wk_assignment_helper","eventUtil"]

    @def_font_size = 10
    @def_tbl_setting = Cargo.tbl_setting

    #編集可否
    @can_edit = ResultCargo.can_edit(@t_date[:t_date],get_uval(:login_id))
    @can_lock = ResultCargo.can_lock_user?(get_uval(:login_id))
    @lock_user = ResultCargo.locked_by(@t_date[:t_date])
    @alert_msg = @lock_user ? "【#{@lock_user[:name]}】が実績登録中です。" : ""
    @cargo_lock_request_info = {
      :work_date=>@t_date[:t_date].strftime("%Y%m%d"),
      :login_id=>get_uval(:login_id),
      :controller=>:result_assignment,
      :action=>:lock
    }

    render :template=>"manager/wk_assignment/index"
  end

  #=== 配番データコピー
  def create
    delay_queue="ResultAssignment_#{params[:work_date]}"
    job = DelayedJob.find_by(["queue like ?","ResultAssignment_%"])
    ret = {:sts=>200,:msg=>nil}
    if job.blank?
      ret = {:sts=>303,:msg=>"配番データコピー中"}
      ResultCargo.delay(queue: "#{delay_queue}").copy_cargo(delay_queue,params[:work_date],get_uval(:login_id))
    elsif job[:last_error].blank?
      ret = {:sts=>500,:msg=>"配番データコピーを実行しています。しばらくお待ちいただいた後に再度実行してください。"}
    else
      ret = {:sts=>500,:msg=>"<b color=red>エラー発生</b><br />この画面のハードコピーを開発会社に連絡してください。<br />#{job[:last_error]}"}
    end
    render :json => ret.to_json, :status => 200 
  end
  #=== 実績更新
  def update
    ret = {:ret=>200,:msg=>""}
    begin
      ResultCargo.transaction do
        (params[:cargo_count].to_i).times{|row_index|
          if ResultCargo.can_edit(@t_date[:t_date],get_uval(:login_id))
            ResultCargo.update_assignment(get_uval(:login_id),@t_date[:t_date],
            params[:conf_flg],params["cargo_#{row_index}"],
            params["wkACargoWorker_#{row_index}"],
            params["wkACargoMachine_#{row_index}"])
          else
            ret[:msg] = "他ユーザにより操作中のため保存を中止しました。"
            flash[:msg] = ret[:msg]
            redirect_to :action=>:index; return;
          end
        }
        if params[:conf_flg].blank?
          Cargo.where(:work_date=>@t_date[:t_date]).update_all(:lock_flg=>0)
          ResultCargo.release(@t_date[:t_date],get_uval(:login_id))
          ret[:msg] = "#{@t_date[:t_date].try(:strftime,"%m/%d")}の実績を保存しました。"
        else
          Cargo.where(:work_date=>@t_date[:t_date]).update_all(:lock_flg=>1)
          ResultCargo.release(@t_date[:t_date],get_uval(:login_id))
          ret[:msg] = "#{@t_date[:t_date].try(:strftime,"%m/%d")}の実績を保存し、公開しました。"
        end
      end
    rescue
      set_error("system_errors.update")
      ret = {:ret=>500,:msg=>flash[:error_msgs]}
    end
    respond_to do |format|
      format.any{}
      format.html{
        if ret[:ret]==200
          if params[:conf_flg].blank?
            flash[:msg] = ret[:msg]
            redirect_to :action=>:index
          else
            flash[:error_msgs] = ret[:msg]
            redirect_to :controller=>:home ,:action=>:menu
            #redirect_to :action=>:index ,:t_date=>(@t_date[:t_date]+1).strftime("%Y%m%d")
          end
        else
          flash[:error_msgs] = ret[:msg]
          redirect_to :controller =>:home,:action=>:error
        end
      }
      format.json{ render :json=>ret.to_json,:status=>200}
    end
  end

  #=== 編集画面ロック
  def lock
    err_msgs = []
    work_date_str = params[:work_date].to_s
    begin
      Date.strptime(work_date_str, "%Y%m%d")
    rescue ArgumentError => e
      err_msgs << "「#{params[:work_date]}」無効な日付形式です。"
    end
    request_user_login_id = params[:request_user]
    user = User.find_by_login_id(request_user_login_id)
    unless user
      err_msgs << "「#{request_user_login_id}」指定ユーザが見つかりませんでした。"
    end

    if err_msgs.length>0
      ret = {sts:400,msg:err_msgs.join("\n")}
      render :json=>ret,:status=>200
      return
    end

    work_date = Date.strptime(work_date_str,"%Y%m%d")
    if ResultCargo.can_edit(work_date,request_user_login_id)
      result = ResultCargo.confine(work_date,request_user_login_id)
      ret = {sts:200,work_date:work_date,request_user:user[:name],result:result}
    else
      lock_user = ResultCargo.locked_by(work_date)
      if lock_user
        err_msgs << "【#{lock_user[:name]}】が配番作業を始めています。"
      else
        err_msgs << "ロックに失敗しました。"
      end
      ret = {sts:400,work_date:work_date,request_user:user[:name],msg:err_msgs.join("\n")}
    end
    render :json=>ret,:status=>200

  end



  private
  #
  #=== 表示対象日付取得：10時以降は翌日
  def get_set_tdate
    @today= Date.today
    if params[:t_date].present? && params[:t_date] =~ /\d{8}/
      session[:t_date] = params[:t_date]
    elsif params[:t_date].blank? && session[:t_date].blank?
      session[:t_date] = @today.strftime("%Y%m%d")
    end
    @t_date = WhCalendar.find_by_t_date(Date.strptime(session[:t_date], "%Y%m%d"))
  end

  def set_my_global_variable
    @my_setting = {:table=>nil,
      :def_where=>[],
      :back_links => [
        {:txt=>I18n.t("btn_labels.link_to",:to=>I18n.t("page_titles.menu")),:path=>{:controller=>:home ,:action => :menu} },
      ],
      :multipart_flg=>false,
    }
    @manager_flg = is_manager?()
  end
end
