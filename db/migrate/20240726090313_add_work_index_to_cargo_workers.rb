class AddWorkIndexToCargoWorkers < ActiveRecord::Migration[7.1]
  def change
    add_column :cargo_workers ,:work_index, :integer, :limit =>1,:comment => "作業順序"
    add_column :cargo_workers ,:bus_flg, :integer, :limit =>1,:comment => "バスフラグ"
    add_column :result_cargo_workers ,:work_index, :integer, :limit =>1,:comment => "作業順序"
    add_column :result_cargo_workers ,:bus_flg, :integer, :limit =>1,:comment => "バスフラグ"
  end
end
