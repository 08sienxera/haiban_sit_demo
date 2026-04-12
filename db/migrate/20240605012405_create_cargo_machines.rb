class CreateCargoMachines < ActiveRecord::Migration[7.1]
  def change
    create_table :cargo_machines,:force => true do |t|
      t.integer :cargo_id, :null =>false ,:comment => "作業"
      t.date :work_date, :null =>false ,:comment => "作業日"
      t.integer :machine_id, :null =>false ,:comment => "機械"
      t.string :machine_cd, :limit =>16, :null =>false ,:comment => "機械番号"
      t.string :wk_type, :limit =>2, :null =>false ,:comment => "作業カテゴリ"
      t.integer :wk_index, :limit =>1, :null =>false ,:comment => "順序"
      t.integer :work_time ,:comment => "稼働時間"
      t.string :m_type, :limit =>2, :null =>false ,:comment => "機械種別"
      t.integer :lock_flg, :limit =>1 ,:comment => "ロック"

      t.integer :lock_version, :default=>1 ,:comment => "ロックバージョン"
      t.datetime :created_at, :null =>false ,:comment => "作成日時"
      t.string :created_uid, :limit =>16, :null =>false ,:comment => "新規登録者ID"
      t.datetime :updated_at, :null =>false ,:comment => "最終更新日時"
      t.string :updated_uid, :limit =>16, :null =>false ,:comment => "更新者ID"
      t.datetime :deleted_at ,:comment => "削除日時"
      t.string :deleted_uid, :limit =>16 ,:comment => "削除者ID"
    end
    add_index :cargo_machines, [:cargo_id], :name =>:cargo_machines_1
    add_index :cargo_machines, [:work_date], :name =>:cargo_machines_2
    add_index :cargo_machines, [:machine_id], :name =>:cargo_machines_3
    add_index :cargo_machines, [:machine_cd], :name =>:cargo_machines_4
  end
end
