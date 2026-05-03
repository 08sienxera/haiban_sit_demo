#= Bos::BoardsControllerを継承
class Officeworker::BoardsController < Bos::BoardsController
  private
  def auth_ck
    ck_officeworker
  end

  def set_my_oth_variable
    super()
    @view_controller = "officeworker/boards"
    @manage_controller = "officeworker/m_boards"
  end

end
