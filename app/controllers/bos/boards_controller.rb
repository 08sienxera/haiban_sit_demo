#= WorkerCommon::BoardsControllerを継承
class Bos::BoardsController < WorkerCommon::BoardsController
  layout "main_layout"
  before_action :set_my_oth_variable

  #=== 掲示詳細画面 
  #自身の投稿掲示の場合、本文確認済み更新
  def show
    if @board.created_uid == get_uval(:login_id)
      @board_target&.confirm_m(get_uval(:login_id))
    end
    super
  end

  
  private
  def auth_ck
    ck_bos
  end
  def set_my_oth_variable
    @links = [{txt:"メニューへ" ,path:{:controller=>:home,:action=>:menu}}]   
    @links << {txt:"掲示一覧へ" ,path:{:action=>:index}} if params["action"]=="show"
    @inc_js = ["manager/board_comment"] 
    @dataline = @board
    @view_controller = "bos/boards"
    @manage_controller = "bos/m_boards"
  end

end
