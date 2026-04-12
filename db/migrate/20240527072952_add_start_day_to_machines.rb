class AddStartDayToMachines < ActiveRecord::Migration[7.1]
  def change
    add_column :machines ,:start_day, :date,:comment => "稼働(導入)開始日"
    add_column :machines ,:last_mainte_day, :date,:comment => "最終メンテナンス日"
    add_column :machine_maintenances ,:maintenanc_type, :integer, :limit =>1,:comment => "分類"
    add_column :machine_maintenances ,:expense, :integer,:comment => "費用"
    add_column :machine_maintenances ,:representative, :string, :limit =>64,:comment => "対応者(責任者"
  end
end
