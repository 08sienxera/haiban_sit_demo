class Manager::CargosController < Manager::HomeController
  layout "main_layout"
  before_action :get_set_tdate
  before_action :set_my_global_variable

  #=== 荷役予定(必要人数設定)画面
  def index
    @title="荷役予定(必要人数設定)"
    #対象日の荷役データを取得
    @datas = Cargo.includes(:cargo_request).where(:work_date=>@t_date[:t_date]).order(:desp_index=>:asc)
    #作業員データの算出
    @woker_sum = Woker.sum_competence(@t_date)
    #指定日コピーの初期値設定
    cp_wh = WhCalendar.where(["t_date < ? and wh_flg = ?",@t_date[:t_date],@t_date[:wh_flg]]).order(:t_date=>:desc).first()
    @cp_date = (cp_wh.present? ? cp_wh[:t_date] : (@today-1))
    #入力フォーマット
    @cc = Cargo.set_input_form("#{Cargo.model_name.name}_in")
    @inc_js= ["manager/cargos"]

    #配番画面リンク権限チェック
    user = User.includes(:user_auth).find(get_uval(:id))
    user_auth = user&.user_auth
    if is_admin? || is_manager?
      @cargo_link_enable = true
    elsif user_auth
      @cargo_link_enable = user_auth[:wk_assignment]&.to_i==1
    else
      @cargo_link_enable = false
    end

    #編集可否
    @can_edit = Cargo.can_edit(@t_date[:t_date],get_uval(:login_id))
    @lock_user = Cargo.locked_by(@t_date[:t_date])
    @alert_msg = @lock_user ? "【#{@lock_user[:name]}】が配番作業を始めています。" : ""


  end
  #
  #===本船作業依頼を反映＆配番開始or指定日沿岸作業コピー
  def create

    # 操作制限中はリダイレクト
    unless @can_edit = Cargo.can_edit(@t_date[:t_date],get_uval(:login_id))
      flash[:msg] = "他ユーザにより配番準備中のため作業依頼取込を中止しました。"
      redirect_to :action=>:index; return
    end

    case params[:mord]
    when "getset"  #作業依頼を反映＆配番開始
      #作業依頼を反映＆配番開始
      begin
        Cargo.transaction do
          Cargo.copy_request(@t_date[:t_date])
        end
      rescue
        set_error("system_errors.update")
        redirect_to :controller =>:home,:action=>:error
        return
      end
      flash[:msg] = "本船作業依頼を反映し、配番中の状態にしました。"
    when "docopy"  #指定日沿岸作業コピー
      pc_work_date = params["#{Cargo.model_name.name}_in"][:work_date]
      if pc_work_date.present?
        begin
          pc_work_date = Date.strptime(pc_work_date, "%Y/%m/%d")
          bace_cargos = Cargo.where({:work_date=>pc_work_date,:cargo_request_id=>0}).order(:desp_index)
          if bace_cargos.blank?
            flash[:msg] = "#{pc_work_date.strftime("%Y/%m/%d")}に沿岸作業の登録が有りません。"
          else
            if params[:do_reset] == "1"
              #指定日の沿岸作業を論理削除
              Cargo.delete_all(get_uval(:login_id),{:work_date=>@t_date[:t_date],:cargo_request_id=>0})
            end
            desp_index = params[:max_desp_index].to_i + 1
            work_no = params[:max_work_no].to_i + 1
            work_no_list = {}
            bace_cargos.each{|bace_cargo|
              datas = {}
              bace_cargo.attribute_names.each{|key|
                case key
                when "deleted_at","deleted_uid" ; datas[key]=nil
                when "id","lock_version" #スキップ
                when "work_date" ; datas[key]=@t_date[:t_date]
                when "desp_index" ; datas[key]=desp_index; desp_index += 1;
                when "work_no"
                  if work_no_list.has_key?(bace_cargo[key])
                    datas[key]=work_no_list[bace_cargo[key]]
                  else
                    datas[key]=work_no
                    work_no_list[bace_cargo[key]]=work_no
                    work_no+=1
                  end
                else ; datas[key]=bace_cargo[key]
                end
              }
              Cargo.create_data(["work_date","desp_index","cargo_request_id"],datas,get_uval(:login_id),false,true)
            }
            flash[:msg] = "#{pc_work_date.strftime("%Y/%m/%d")}の沿岸作業をコピーしました。"
          end
        rescue
          set_error("system_errors.update")
          redirect_to :controller =>:home,:action=>:error
          return
        end
      end
    end
    redirect_to :action=>:index
  end
  
  #
  #=== 荷役予定登録処理
  def update
    # 操作制限中はリダイレクト
    unless @can_edit = Cargo.can_edit(@t_date[:t_date],get_uval(:login_id))
      flash[:msg] = "他ユーザにより配番準備中のため作業依頼の更新を中止しました。"
      redirect_to :action=>:index; return
    end

    row_count = params[:row_count].to_i
    begin
      Cargo.transaction do
        @cc = Cargo.set_input_form("#{Cargo.model_name.name}_in")
        t_date = Date.strptime(params[:id], "%Y%m%d")
        #一旦指定日の全データを論理削除
        Cargo.delete_all(get_uval(:login_id),{:work_date=>t_date})
        #行数分取込み
        1.upto(row_count){|row_index|
          @cc.setgname("#{Cargo.model_name.name}_in_#{row_index}")
          if params[@cc.getgname].present?
            if @cc.setpostdata(params)
              datas = @cc.mksqldata(get_uval(:login_id)).merge({"work_date"=>t_date})
              datas["cargo_request_id"] = 0 if datas["cargo_request_id"].blank?
              cargo = Cargo.create_data("id",datas,get_uval(:login_id),false,true)
              cargo.recalculate_work_time(get_uval(:login_id))

            # else
            #   p @cc.get_all_paramsdata("msg")
            end
          end
        }
      end
      flash[:msg] = "荷役予定を登録しました。"
    rescue
      set_error("system_errors.update")
      redirect_to :controller =>:home,:action=>:error
      return
    end
    redirect_to :action=>:index,:t_date=>params[:id]
  end

  private
  #
  #=== 表示対象日付取得：10時以降は翌日(変更)→常に翌日
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
    @my_setting = {:table=>Cargo,
      :def_where=>[],
      :back_links => [
        {:txt=>I18n.t("btn_labels.link_to",:to=>I18n.t("page_titles.menu")),:path=>{:controller=>:home ,:action => :menu} },
      ],
      :multipart_flg=>false,
      }
  end
end
