#= Manager::WkAssignmentControllerを継承
class Officeworker::WkAssignmentController < Manager::WkAssignmentController
  skip_before_action :ck_manager
  before_action :ck_officeworker, :except=>[:error]

  #=== 配番割当画面 Number assignment screen
  #読込テンプレートを制御 Control the loading template
  def index
    super()
    render :template=>"manager/wk_assignment/index"
  end
end
