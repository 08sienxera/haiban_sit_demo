class AddPayloadToDelayedJobMsgs < ActiveRecord::Migration[7.1]
  def change
    add_column :delayed_job_msgs ,:payload, :text,:comment => "ペイロード"
  end
end
