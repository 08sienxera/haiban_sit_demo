#= Manager::PrintFilesControllerを継承 
class Officeworker::PrintFilesController < Manager::PrintFilesController
  skip_before_action :ck_manager
  before_action :ck_officeworker, :except=>[:error]
end


