#= Manager::CargoRequestsControllerを継承
class Officeworker::CargoRequestsController < Manager::CargoRequestsController
  skip_before_action :ck_manager
  before_action :ck_officeworker, :except=>[:error]
  #=== 作業依頼画面 Work request screen
  #読込テンプレートを制御 Controlling the loading template
  def index
    super()
    render :template=>"manager/cargo_requests/index"
  end
end
