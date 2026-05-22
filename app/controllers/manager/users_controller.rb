#= ユーザマスタ User master
class Manager::UsersController < Manager::HomeController
  before_action :set_my_global_variable
  before_action :set_my_index_variable
  before_action :set_my_oth_variable,:except=>:index
  before_action :set_my_csv_variable,:only=>[:csv_in,:csv_input]

  #=== 更新画面を表示 Display update screen
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
    @cc.setparam('password','value',"")
  end

  #=== ユーザ操作機能 User operation function
  # リクエストパラメータ request parameters
  # opt : 実行内容を指定 Specify execution content
  # id : 対象ユーザID Target user ID
  def show
    dataline = @my_setting[:table].find(params[:id])
    case params[:opt]
    # 初回ログイン状態にリセット  Reset to initial login state
    when "reset"
      dataline[:last_logined_at] = nil
      dataline[:remind_question] = nil
      dataline[:remind_answer] = nil
      dataline.save
      redirect_to :action=>:index
    else
    # 指定ユーザ情報をjsonで返す Return specified user information in JSON format.
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
  end
  private
  def set_my_global_variable
    @my_setting = {:table=>User,
      :def_where=>["login_id<>?",User::SIT_Admin],
      :back_links => [{:txt=>I18n.t("btn_labels.link_to",:to=>I18n.t("page_titles.menu")),
          :path=>{:controller=>:home ,:action => :menu} }],
      :multipart_flg=>false,
      }
  end
  def set_my_index_variable
    @my_setting[:order] = :login_id
    @my_setting[:csv_in] = true
    @my_setting[:new_in] = true
    @my_setting[:new_copy] = false
  end
  def set_my_oth_variable
    @my_setting[:tbl_optins] = {:class=>"soloidline"}
    @my_setting[:destroy] = true
    @my_setting[:table_keys] = "login_id"
    @my_setting[:msg_key] = "name"
    @my_setting[:back_links] << {:txt=>I18n.t("btn_labels.link_to",:to=>I18n.t("page_titles.index",
          :name=>@my_setting[:table].model_name.human)),
          :path=>{:action => :index} }
  end
  def set_my_csv_variable
    @my_setting[:table_keys] = ["login_id"]
  end

end
