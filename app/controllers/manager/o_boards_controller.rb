#= WorkerCommon::BoardsControllerを継承
class Manager::OBoardsController < Bos::BoardsController

  def show
    super()
    render :template=>"bos/boards/show"
  end

  private
  def auth_ck
    ck_manager
  end
  def set_my_oth_variable
    super()
    @view_controller = "manager/o_boards"
    @manage_controller = "manager/boards"
  end

end
