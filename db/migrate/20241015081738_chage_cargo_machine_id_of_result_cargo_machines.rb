class ChageCargoMachineIdOfResultCargoMachines < ActiveRecord::Migration[7.1]
  def up
    change_column :result_cargo_workers ,:cargo_worker_id, :integer, :null =>true,:comment => "作業従事"
    change_column :result_cargo_machines ,:cargo_machine_id, :integer, :null =>true,:comment => "作業従事機械"
  end
  def down
    change_column :result_cargo_workers ,:cargo_worker_id, :integer, :null =>false,:comment => "作業従事"
    change_column :result_cargo_machines ,:cargo_machine_id, :integer, :null =>false,:comment => "作業従事機械"
  end
end
