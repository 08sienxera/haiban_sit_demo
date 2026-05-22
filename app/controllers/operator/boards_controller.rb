class Operator::BoardsController < WorkerCommon::BoardsController
  layout "operator_layout"
  #=== 権限チェック Permission check
  #現場作業員であること Being a field worker
  def auth_ck
    ck_operator
  end


end
