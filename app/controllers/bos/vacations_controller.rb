#= Manager::VacationsControllerを継承
class Bos::VacationsController < Manager::VacationsController
  skip_before_action :ck_manager
  before_action :ck_bos, :except=>[:error]

  

end
