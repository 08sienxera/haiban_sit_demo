#= Manager::WkAssignmentControllerを継承
class Bos::WkAssignmentController < Manager::WkAssignmentController
  skip_before_action :ck_manager
  before_action :ck_bos, :except=>[:error]
end
