#= Manager::BoardsControllerを継承
class Officeworker::MBoardsController < Manager::BoardsController
  skip_before_action :ck_manager
  before_action :ck_officeworker, :except=>[:error]

  #=== 掲示詳細画面
  #読込テンプレートを制御
  def show
    super()
    render :template=>"manager/boards/show"
  end
end
