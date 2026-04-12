class Officeworker::ExternalDatasController < Manager::ExternalDatasController
  skip_before_action :ck_manager
  before_action :ck_officeworker, :except=>[:error]
end

