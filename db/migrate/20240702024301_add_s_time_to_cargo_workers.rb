class AddSTimeToCargoWorkers < ActiveRecord::Migration[7.1]
  def change
    add_column :cargo_workers ,:s_time, :time,:comment => "開始時刻"
    add_column :cargo_workers ,:e_time, :time,:comment => "終了予定時刻"
  end
end
