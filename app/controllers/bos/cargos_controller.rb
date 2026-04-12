#= Manager::CargosControllerを継承
class Bos::CargosController < Manager::CargosController
  skip_before_action :ck_manager
  before_action :ck_bos, :except=>[:error]

  #=== 配番登録画面
  #読込テンプレートを制御
  def index
    super()
    render :template=>"manager/cargos/index"
  end
end
