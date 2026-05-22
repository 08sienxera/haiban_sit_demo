#= 昼食集計帳票エクセル作成クラス Lunchtime summary report Excel creation class
class Officeworker::LunchSummaryController < Manager::LunchSummaryController
  skip_before_action :ck_manager, :except => [:error]
  before_action :ck_officeworker, :except => [:error]
end
