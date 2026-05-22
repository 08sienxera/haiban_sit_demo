class Officeworker::LunchOrdersController < Manager::LunchOrdersController
  skip_before_action :ck_manager
  before_action :ck_officeworker, :except=>[:error]

  def index
    super()
    render :template => 'manager/lunch_orders/index'
  end

  #===昼食更新画面 Lunch update screen
  def edit
    @title = "昼食更新"
    render :template=>"manager/lunch_orders/edit"
  end
  
end

