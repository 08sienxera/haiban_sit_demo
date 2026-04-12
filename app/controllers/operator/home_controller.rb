class Operator::HomeController < ApplicationController
  # 共有レイアウト呼出し
  layout 'operator_layout'
  before_action :login_ck, :except => [:error]
  before_action :ck_operator, :except => [:error]

  #=== メニュー画面
  def menu
    @title = "トップ"
    @lunch_date = LunchOrder.get_today
    @work_date = Date.today()
    
    @branch_cd = get_uval(:branch_cd)
    @inc_css = [:operator_vacation]
  end

  #=== エラー画面
  def error
  end

end