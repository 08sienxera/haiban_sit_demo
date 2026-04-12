#= Manager::ResultAssignmentControllerを継承 
class Bos::ResultAssignmentController < Manager::ResultAssignmentController
  skip_before_action :ck_manager
  before_action :ck_bos, :except=>[:error]
end
