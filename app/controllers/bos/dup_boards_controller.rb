#= 変更により未使用、旧版
class Bos::DupBoardsController < Manager::BoardsController
  layout "main_layout"
  before_action :ck_bos, :except => [:error]
  before_action :set_my_global_variable
  before_action :set_my_oth_variable,:except=>:index
  before_action :set_my_index_variable
  before_action :set_js,:only=>:edit
  after_action :set_board,:only=>[:create,:update]

  #--
  def index
    redirect_to :controller=>:boards,:action=>:index
  end
  def edit
    board = Board.find(params[:id])
    unless board.created_uid == get_uval(:login_id)
      set_error("system_errors.page_link")
      redirect_to :controller=>:home ,:action => :error
      return
    end
    super
  end
  #++

  private
  def ck_manager
  end

end
