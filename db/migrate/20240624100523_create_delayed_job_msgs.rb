class CreateDelayedJobMsgs < ActiveRecord::Migration[7.1]
  def change
    create_table :delayed_job_msgs do |t|
      t.integer :delayed_job_id, :default=>0 ,:comment => "JobId"
      t.text :msg ,:comment => "メッセージ"
      t.text :queue ,:comment => "キュー"
      t.datetime :created_at ,:comment => "作成日時"
      t.datetime :updated_at ,:comment => "最終更新日時"
    end
    add_index :delayed_job_msgs, [:delayed_job_id], :name =>:delayed_job_msgs_1
  end
end
