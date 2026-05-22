#= Operator::MyVacationsControllerを継承
class Bos::MyVacationsController < Operator::MyVacationsController
  skip_before_action :ck_operator
  before_action :ck_bos, :except=>[:error]
  
  #=== 休暇登録画面 Vacation screen
  #読込テンプレートを制御 Control the loading template
  def index
    super()
    # render :template=>"operator/my_vacations/index"
  end


end