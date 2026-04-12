class AddWorkIndexToCargoMachinesAndResultCargoMachines < ActiveRecord::Migration[7.1]
  def change
    add_column :cargo_machines ,:work_index, :integer, :limit =>1,:comment => "使用順序"
    add_column :result_cargo_machines ,:work_index, :integer, :limit =>1,:comment => "使用順序"
  end
end
