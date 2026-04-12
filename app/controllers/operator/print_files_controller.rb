#= Manager::PrintFilesControllerを継承 
class Operator::PrintFilesController < Manager::PrintFilesController
  skip_before_action :ck_manager
  before_action :ck_operator, :except=>[:error]

end


