#= Manager::DelayedJobsControllerを継承
class Bos::DelayedJobsController < Manager::DelayedJobsController
  skip_before_action :ck_manager
  before_action :ck_bos, :except=>[:error]
  private
end
