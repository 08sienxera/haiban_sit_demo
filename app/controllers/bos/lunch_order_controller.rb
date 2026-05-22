#= Operator::LunchOrderControllerを継承
class Bos::LunchOrderController < Operator::LunchOrderController
  skip_before_action :ck_operator, :except => [:error]
  before_action :ck_bos, :except => [:error]
  before_action :set_my_oth_variable,only:[:edit,:update]

  #=== 昼食注文画面 Lunch order screen
  def edit
    super()
    render :template=>"operator/lunch_order/edit"
  end

  def history
    super()
    render :template=>"operator/lunch_order/history"
  end

end
