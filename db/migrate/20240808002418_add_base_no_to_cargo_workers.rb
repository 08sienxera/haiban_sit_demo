class AddBaseNoToCargoWorkers < ActiveRecord::Migration[7.1]
  def change
    add_column :cargo_workers ,:base_no, :integer, :default=>1,:comment => "登録時休暇申請状況"
  end
end
