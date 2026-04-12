class Bos::ExternalDatasController < Manager::ExternalDatasController
  skip_before_action :ck_manager
  before_action :ck_bos, :except=>[:error]


end

