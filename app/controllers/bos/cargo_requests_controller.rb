#= Manager::CargoRequestsControllerを継承
class Bos::CargoRequestsController < Manager::CargoRequestsController
  skip_before_action :ck_manager
  before_action :ck_bos, :except=>[:error]
  #=== 作業依頼画面 Work request screen
  #読込テンプレートを制御 Control the loading template
  def index
    super()
    render :template=>"manager/cargo_requests/index"
  end
end
