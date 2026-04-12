class CreateDelayedJobs < ActiveRecord::Migration[7.1]
  def change
    create_table :delayed_jobs do |t|
      t.integer :priority, :default=>0 ,:comment => "優先度"
      t.integer :attempts, :default=>0 ,:comment => "実行回数"
      t.text :handler ,:comment => "ハンドル"
      t.text :last_error ,:comment => "最終エラー"
      t.datetime :run_at ,:comment => "実行日時"
      t.datetime :locked_at ,:comment => "ロック日時"
      t.datetime :failed_at ,:comment => "エラー日時"
      t.string :locked_by ,:comment => "ロック"
      t.text :queue ,:comment => "キュー"

      t.datetime :created_at ,:comment => "作成日時"
      t.datetime :updated_at ,:comment => "最終更新日時"
    end
    add_index :delayed_jobs, [:priority,:run_at], :name =>:delayed_jobs_1
  end
end
