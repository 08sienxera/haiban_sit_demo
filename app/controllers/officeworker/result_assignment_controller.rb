#= Manager::ResultAssignmentControllerを継承 
class Officeworker::ResultAssignmentController < Manager::ResultAssignmentController
  skip_before_action :ck_manager
  before_action :ck_officeworker, :except=>[:error]
end
