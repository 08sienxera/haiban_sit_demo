#= Manager::VacationsControllerを継承
class Officeworker::VacationsController < Manager::VacationsController
  skip_before_action :ck_manager
  before_action :ck_officeworker, :except=>[:error]
end