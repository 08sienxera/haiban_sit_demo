class CreateMachineMaintenances < ActiveRecord::Migration[7.1]
  def change
    create_table :machine_maintenances do |t|
      t.integer :machine_id, :null =>false ,:comment => "機械_id"
      t.date :s_date, :null =>false ,:comment => "メンテナンス開始日"
      t.date :e_date ,:comment => "メンテナンス終了日"
      t.string :note ,:comment => "メンテナンス内容"
      t.integer :lock_version, :default=>1 ,:comment => "ロックバージョン"
      t.datetime :created_at, :null =>false ,:comment => "作成日時"
      t.string :created_uid, :limit =>16, :null =>false ,:comment => "新規登録者ID"
      t.datetime :updated_at, :null =>false ,:comment => "最終更新日時"
      t.string :updated_uid, :limit =>16, :null =>false ,:comment => "更新者ID"
      t.datetime :deleted_at ,:comment => "削除日時"
      t.string :deleted_uid, :limit =>16 ,:comment => "削除者ID"
    end
    add_index :machine_maintenances, [:machine_id], :name =>:machine_maintenances_1
    add_index :machine_maintenances, [:s_date], :name =>:machine_maintenances_2
    add_index :machine_maintenances, [:e_date], :name =>:machine_maintenances_3
  end
end
