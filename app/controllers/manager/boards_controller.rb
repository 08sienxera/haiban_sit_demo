class Manager::BoardsController < Manager::HomeController
  layout "main_layout"
  before_action :set_my_global_variable
  before_action :set_my_oth_variable,:except=>:index
  before_action :set_my_index_variable
  before_action :set_target_user,:only=>[:new,:edit]
  after_action :set_board,:only=>[:create,:update]


  #=== 掲示閲覧一覧画面(管理)
  def show
    @title="掲示閲覧一覧"
    begin
      @board = Board.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      set_error("system_errors.page_link",nil)
      redirect_to :controller =>:home,:action=>:menu
      return
    end
    @ss = BoardTarget.set_serch_form("board_target_serch")
    @ss.setpostdata(params,session[:serch_data])
    def_where = ["board_id=? and (wokers.applicable is null or wokers.applicable = ?)",@board[:id],Applicable.get_applicable(2)]
    condition = @ss.mksqlwhere(def_where)
    order = {"wokers.branch_cd"=>:asc,"wokers.desp_index"=>:asc}
    @datas = BoardTarget.get_list(get_page(params,@ss),nil,condition,order,{:user=>:woker})
    @tab_keys=["confirmation_m_at"]
  end

  #=== 掲示新規登録画面
  def new
    @inc_js ||= []
    @inc_js << "manager/board_target.js"
    @title = "掲示 新規登録"
  end

  #=== 掲示更新画面
  def edit
    @title = "掲示 更新"
  end
  
  def create
    file_params = params["Board_in"].slice("file_name","file_name2","file_name3","file_name4","file_name5")
    file_params.each do |pkey,pvalue|
      next if pvalue.size < 2
      params["Board_in"][pkey] = pvalue[1]
    end

    board_targets = params[:board_targets]
    params["Board_in"]["board_group_id"] = "0" if params["Board_in"]["board_group_id"].blank?
    params["board_group_id"] = "0" if params["board_group_id"].blank?
    # 掲示公開対象（after_actionで使用
    if board_targets.present?
      require 'json'
      @board_target_reg_list = JSON.parse(board_targets)
    else
      @board_target_reg_list = []
    end
    super()
  end

  def update
    file_params = params["Board_in"].slice("file_name","file_name2","file_name3","file_name4","file_name5")
    file_params.each do |pkey,pvalue|
      next if pvalue.size < 2
      params["Board_in"][pkey] = pvalue[1]
    end

    board_targets = params[:board_targets]
    params["Board_in"]["board_group_id"] = "0" if params["Board_in"]["board_group_id"].blank?
    params["board_group_id"] = "0" if params["board_group_id"].blank?

    # 掲示公開対象（after_actionで使用
    if board_targets.present?
      require 'json'
      @board_target_reg_list = JSON.parse(board_targets)
    else
      @board_target_reg_list = []
    end
    super()

  end

  private
  def set_my_global_variable
    @my_setting = {:table=>Board,
      :def_where=>[],
      :back_links => [
        {:txt=>I18n.t("btn_labels.link_to",:to=>I18n.t("page_titles.menu")),:path=>{:controller=>:home ,:action => :menu} },
      ],
      :multipart_flg=>true,
      }
  end
  def set_my_oth_variable
    @my_setting[:tbl_optins] = {:class=>"soloidline"}
    @my_setting[:destroy] = true
    @my_setting[:table_keys] = "id"
    @my_setting[:msg_key] = "name"
    @my_setting[:file_keys] = ["file_name","file_name2","file_name3","file_name4","file_name5"]
    @my_setting[:back_links] << {
      :txt=>I18n.t("btn_labels.link_to",:to=>I18n.t("page_titles.index",:name=>@my_setting[:table].model_name.human)),
      :path=>{:action => :index}
    }

  end
  def set_my_index_variable
    @my_setting[:order] = {:id=>:desc}
    @my_setting[:csv_in] = false
    @my_setting[:new_in] = true
    @my_setting[:new_copy] = false
    
    # 自身の送信した掲示のみ表示
    @my_setting[:def_where] = is_manager? ? [] : ["created_uid = ?",get_uval(:login_id)]

  end
  
  #掲示対象フォーム用　ユーザデータ、選択済みユーザリスト
  def set_target_user
    @get_board_target_req_url = url_for(:controller=>:board_groups,:action=>:get_target_users,:id=>"__board_group_id__")
    @board_targets = []
    @board = Board.includes(:board_comment).find_by_id(params[:id])
    @dataline = @board
    target_login_ids = @board.present? ? BoardTarget.where(:board_id=>@board.id)&.pluck(:login_id) : []
    @board_targets = User.where(:login_id=>target_login_ids).pluck(:name,:login_id)
    # 掲示公開グループフォーム用
    @board_group_list = {}
    BoardGroup.all.each do |bg|
      t_user_list = bg.get_user_list
      users = User.where(:login_id=>t_user_list).map{|user| [user.login_id,user.name]}
      @board_group_list["#{bg[:name]}_#{bg[:id]}"]  = users
    end
    # ユーザ選択フォーム用
    @user_list = {}
    User.where(:auth_flg=>0..4).each do |user|
      @user_list[user.auth_flg] ||= []
      @user_list[user.auth_flg] << [user.login_id,user.name,@board_targets.any?{|_,login_id| user.login_id==login_id}]
    end
    @user_list.transform_keys!{|key| User::AuthFlg.find{|name,cd| key==cd.to_i}[0]+"_#{key}"}

    @cc = Board.set_input_form("#{Board.model_name.name}_in")
    @cc.setdbdata(@board)
    user_select_button_html = []
    user_select_button_html << "<button class='btn' style='margin: 5px 0px 5px 10px;' onclick='openForm(event,\"user\")'>対象者選択</button>"
    user_select_button_html << "<button class='btn' style='margin: 5px 0px 5px 10px;' onclick='openForm(event,\"group\")'>公開対象グループ選択</button>"
    @cc.setparams("board_targets",{"title"=>"公開対象","type"=>"select",'size'=>"3","maxlength"=>"8","inputFlg"=>1,"essFlg"=>0,"align"=>"L",
      "list"=>@board_targets,"defVal"=>"1","bwd"=>user_select_button_html.join("")})
    @cc.set_index("board_targets",1)
  end

  #掲示の後処理
  def set_board
    #PDFファイルの画像化&対象者設定＆メール通知
    @dataline ||= Board.last
    return if @dataline.blank?
    if Rails.env.development?
      @dataline.set_after_update(@board_target_reg_list)
    else
      @dataline.delay.set_after_update(@board_target_reg_list)
    end
  end
  
end
