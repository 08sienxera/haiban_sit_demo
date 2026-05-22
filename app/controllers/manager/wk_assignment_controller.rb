class Manager::WkAssignmentController < Manager::HomeController
  layout "main_layout"
  before_action :get_set_tdate
  before_action :set_my_global_variable


  #=== 編集画面ロック Edit screen lock
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
      if Cargo.can_edit(work_date,request_user_login_id)
        result = Cargo.confine(work_date,request_user_login_id)
        ret = {sts:200,work_date:work_date,request_user:user[:name],result:result}
      else
        lock_user = Cargo.locked_by(work_date)
        if lock_user
          err_msgs << "【#{lock_user[:name]}】が配番作業を始めています。"
        else
          err_msgs << "ロックに失敗しました。"
        end
        ret = {sts:400,work_date:work_date,request_user:user[:name],msg:err_msgs.join("\n")}
      end
      render :json=>ret,:status=>200

    end


  #=== 配番割当画面 Number assignment screen
  def index
    @title=I18n.t("page_titles.wk_assignment")
    @cargo = Cargo.where({:work_date=>@t_date[:t_date]}).order(:desp_index).preload([:cargo_worker,:cargo_machine])
    #配番ユーザデータ取得 Retrieve assigned user data
    this_mm = get_month(@t_date[:t_date])
    @branches = Branche.get_assignment_list(@t_date[:t_date])
    @wokers,@woker_names = Woker.get_assignment_list(@t_date,@branches,this_mm)
    #休暇種別 Leave type
    @vacation_types = {"0"=>"公休日"}.merge(VacationType.getdatalist({:key=>:base_no,:text=>:name,:type=>"hash"}))
    #配番機械データ取得 Machine assignment data acquisition
    @machines,@machine_names,@machine_bgc_class = Machine.get_assignment_list(@t_date[:t_date])
    #言付けデータ取得 Message data acquisition
    @msgs = CargoMsg.get_assignment_list(@t_date[:t_date])
    
    #表示設定 Display settings
    @inc_css = [:wk_assignment]
    @inc_js= ["manager/commn_assignment","manager/wk_assignment","manager/wk_assignment_helper","eventUtil"]
    @def_font_size = 10
    @def_tbl_setting = Cargo.tbl_setting

    #編集可否 Editability
    @can_edit = Cargo.can_edit(@t_date[:t_date],get_uval(:login_id))
    @can_lock = Cargo.can_lock_user?(get_uval(:login_id))
    @lock_user = Cargo.locked_by(@t_date[:t_date])
    @alert_msg = @lock_user ? "【#{@lock_user[:name]}】が配番作業を始めています。" : ""
    @cargo_lock_request_info = {
      :work_date=>@t_date[:t_date].strftime("%Y%m%d"),
      :login_id=>get_uval(:login_id),
      :controller=>:wk_assignment,
      :action=>:lock
    }
  end

  #=== 自動配番 Automatic numbering
  def create
    delay_queue="WkAssignment_#{params[:work_date]}"
    job = DelayedJob.find_by(["queue like ?","WkAssignment_%"])
    ret = {:sts=>200,:msg=>nil}
    case params[:mord]
    when "copyFM","copyDM","mkAssignment"
    if job.blank?
      case params[:mord]
      when "copyFM" ; ret = {:sts=>303,:msg=>"前回FM配番コピー中"}
      when "copyDM" ; ret = {:sts=>303,:msg=>"前回DM配番コピー中"}
      when "mkAssignment" ; ret = {:sts=>303,:msg=>"自動配番中"}
      end
      Cargo.delay(queue: "#{delay_queue}").mk_assignment(delay_queue,params[:work_date],params[:mord])
    elsif job[:last_error].blank?
      ret = {:sts=>500,:msg=>"他の作業を実行しています。しばらくお待ちいただいた後に再度実行してください。"}
    elsif !Cargo.can_edit(Date.strptime(params[:work_date],"%Y%m%d"),get_uval(:login_id))
      ret = {:sts=>500,:msg=>"他ユーザにより配番作業中のため自動配番を中止しました。"}
    else
      ret = {:sts=>500,:msg=>"<b color=red>エラー発生</b><br />この画面のハードコピーを開発会社に連絡してください。<br />#{job[:last_error]}"}
    end
    when "check"
      if job.blank?
        ret = {:sts=>200,:msg=>"完了しました。"}
      elsif job[:last_error].blank?
        case job[:queue]
        when "#{delay_queue} copyFM" ; ret = {:sts=>303,:msg=>"前回FM配番コピー中"}
        when "#{delay_queue} copyDM" ; ret = {:sts=>303,:msg=>"前回DM配番コピー中"}
        when "#{delay_queue} mkAssignment" ; ret = {:sts=>303,:msg=>"自動配番中"}
        else ; ret = {:sts=>500,:msg=>"設定不良。動作モード[#{job[:queue]}]は定義されていません。"}
        end
      else
        ret = {:sts=>500,:msg=>"<span class=err>エラー発生</span><br />この画面のハードコピーを開発会社に連絡してください。<br />#{job[:last_error].gsub("\n","<br />")}"}
      end
    else ; ret = {:sts=>500,:msg=>"設定不良。動作モード[#{params[:mord]}]は定義されていません。"}
    end
    render :json => ret.to_json, :status => 200 
  end

  #=== 配番更新 Update numbering
  def update
    ret = {:ret=>200,:msg=>""}
    sm = Time.now
    begin
      Cargo.transaction do
        (params[:cargo_count].to_i).times{|row_index|
          s = Time.now
          if Cargo.can_edit(@t_date[:t_date],get_uval(:login_id))
            Cargo.update_assignment(get_uval(:login_id),@t_date[:t_date],
              params[:conf_flg],params["cargo_#{row_index}"],
              params["wkACargoWorker_#{row_index}"],
              params["wkACargoMachine_#{row_index}"]
            )
          else
            ret[:msg] = "他ユーザにより操作中のため保存を中止しました。。"
            flash[:msg] = ret[:msg]
            redirect_to :action=>:index; return;
          end
        }
        if params[:conf_flg].blank?
          Cargo.release(@t_date[:t_date],get_uval(:login_id))
          ret[:msg] = "#{@t_date[:t_date].try(:strftime,"%m/%d")}の配番を保存しました。"
        else
          Cargo.release(@t_date[:t_date],get_uval(:login_id))
          ret[:msg] = "#{@t_date[:t_date].try(:strftime,"%m/%d")}の配番を保存し、公開しました。"
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
          end
        else
          flash[:error_msgs] = ret[:msg]
          redirect_to :controller =>:home,:action=>:error
        end
      }
      format.json{ render :json=>ret.to_json,:status=>200}
    end
  end
  
  #=== 力量設定 Competence setting
  def set_competence
    ret = {:sts=>200,:msg=>nil}
    begin
      dataline = Woker.find(params[:woker_id])
      dataline["competence_#{params[:competence_key]}"] = params[:level].to_i
      dataline[:updated_uid] = get_uval(:login_id)
      dataline.save
    rescue
      ret[:sts]=500
      ret[:msg]=$!.to_s
    end
    render :json => ret.to_json, :status => 200 
  end
  
  #=== 言付け更新 Update of instructions
  def set_msg
    ret = {:sts=>200,:msg=>nil}
    begin
      dataline = CargoMsg.find_by(:work_date=>params[:work_date],:login_id=>params[:login_id])
      if dataline.blank?
        dataline = CargoMsg.new({
          :work_date => params[:work_date],
          :login_id => params[:login_id],
          :user_id => params[:user_id],
          :created_uid => get_uval(:login_id)})
      end
      dataline[:msg] = params[:msg]
      dataline[:created_uname] = params[:created_uname]
      dataline[:updated_uid] = get_uval(:login_id)
      dataline.save
    rescue
      ret[:sts]=500
      ret[:msg]=$!.to_s
    end
    render :json => ret.to_json, :status => 200 
  end

  private
  #
  #=== 表示対象日付取得：10時以降は翌日(変更)→常に翌日 Display target date acquisition: After 10:00, it will be the next day (changed) → Always the next day
  def get_set_tdate
    @today= Date.today
    t_date = @today+1
    # t_date = (Time.now.hour < 10 ? @today : (@today+1))
    if params[:t_date].present? && params[:t_date] =~ /\d{8}/
      session[:t_date] = params[:t_date]
    elsif params[:t_date].blank? && session[:t_date].blank?
      session[:t_date] = t_date.strftime("%Y%m%d")
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
