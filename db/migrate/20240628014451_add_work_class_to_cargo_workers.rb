class AddWorkClassToCargoWorkers < ActiveRecord::Migration[7.1]
  def change
    add_column :cargo_workers ,:work_class, :integer, :limit =>1,:comment => "作業区分"
  end
end
