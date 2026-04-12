#= Manager::PrintFilesControllerを継承 
class Bos::PrintFilesController < Manager::PrintFilesController
  skip_before_action :ck_manager
  before_action :ck_bos, :except=>[:error]
end


