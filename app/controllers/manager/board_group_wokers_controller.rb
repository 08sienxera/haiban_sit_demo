class Manager::BoardGroupWokersController < Manager::HomeController
  layout "main_layout"
  before_action :set_my_global_variable


  # 掲示対象者設定画面 Target setting
  def edit
    @branche_color = Branche.get_color_list(t_date=Date.today)
    condition = ["board_group_id = ?",@board_group[:id]]
    applicable = Applicable.get_applicable(2)
    # @registered_list = BoardGroupWoker.includes(:user=>:woker).references(:user=>:woker).where(condition).order("wokers.branch_cd"=>:asc,"wokers.desp_index"=>:asc)

    @registered_list = BoardGroupWoker
      .joins(:user)
      .where(condition)
      .order("users.login_id"=>:asc)
    @wokers = Woker.get_latest(Date.today).where(:login_id=>@registered_list.pluck(:login_id)).order("branch_cd"=>:asc,"desp_index"=>:asc)
    @ss = User.set_serch_form("board_group_serch")
    @target_list={}
  end

  # 掲示対象者更新処理 Target update
  def update
    begin
      BoardGroup.transaction do
        #一旦全対象者を論理削除 Delete all
        BoardGroupWoker.delete_all(get_uval(:login_id),{:board_group_id=>@board_group[:id]})
        t_count = 0
        params[:login_id].each{|login_id|
          BoardGroupWoker.create_data([:board_group_id,:login_id],{:board_group_id=>@board_group[:id],:login_id=>login_id},get_uval(:login_id),false,true)
          t_count += 1
        }unless params[:login_id].blank?
        #掲示済みの対象者更新 Update
        if Rails.env.development?
          @board_group.resettting_target
        else
          @board_group.delay.resettting_target
        end
        flash[:msg] = "#{@board_group[:name]}の対象者#{t_count}名を保存しました。"
      end
    rescue
      set_error("system_errors.update")
      redirect_to :controller =>:home,:action=>:error
      return
    end
    redirect_to :controller => 'manager/board_groups', :action=>:index
  end

  # 掲示対象者を返す Return
  def show
    @ss = User.set_serch_form("board_group_serch")
    @ss.setpostdata(params,session[:serch_data])
    def_where = ["users.login_id<> ? and (wokers.applicable is null or wokers.applicable = ?) ",User::SIT_Admin,Applicable.get_applicable(2)]
    unless params[:registered].blank?
      def_where[0] << "and not users.login_id in (?)"
      def_where << params[:registered]
    end
    condition = @ss.mksqlwhere(def_where)
    @target_list = User.includes(:woker).references(:woker).where(condition).order("wokers.branch_cd"=>:asc,"wokers.desp_index"=>:asc)
    render :layout => nil
  end

  private
  def set_my_global_variable
    @title="掲示対象者設定"
    @my_setting = {:table=>BoardGroup,
      :def_where=>[],
      :back_links => [
        {:txt=>I18n.t("btn_labels.link_to",:to=>I18n.t("page_titles.menu")),:path=>{:controller=>:home ,:action => :menu} },
        {:txt=>I18n.t("btn_labels.link_to",:to=>I18n.t("page_titles.index",:name=>I18n.t("activerecord.models.board_group"))),:path=>{:controller=>:board_groups,:action=>:index}}
      ],
      :multipart_flg=>false,
      }
    begin
      @board_group = BoardGroup.find(params[:id])
      raise ActiveRecord::RecordNotFound.new() unless @board_group.can_mod_group_type?
    rescue ActiveRecord::RecordNotFound
      set_error("system_errors.page_link",nil)
      redirect_to :controller =>:home,:action=>:menu
      return
    end
  end
end
