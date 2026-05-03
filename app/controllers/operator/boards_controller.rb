class Operator::BoardsController < WorkerCommon::BoardsController
  layout "operator_layout"
  #=== 権限チェック
  #現場作業員であること
  def auth_ck
    ck_operator
  end


end
