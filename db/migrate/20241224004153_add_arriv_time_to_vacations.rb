class AddArrivTimeToVacations < ActiveRecord::Migration[7.1]
  def change
    add_column :vacations ,:arriv_time, :string, :limit =>8,:comment=>"出勤希望時刻"
  end
end
