class CreateLunchOrderLocks < ActiveRecord::Migration[7.1]
  def change
    create_table :lunch_order_locks do |t|
      t.date :order_date, :null =>false ,:comment => "注文日"
      t.string :branche_cd, :limit =>8 ,:comment => "注文者グループCD"
      t.integer :lock_flg, :limit =>1 ,:comment => "ロックフラグ"

      t.integer :lock_version, :default=>1 ,:comment => "ロックバージョン"
      t.datetime :created_at, :null =>false ,:comment => "作成日時"
      t.string :created_uid, :limit =>16, :null =>false ,:comment => "新規登録者ID"
      t.datetime :updated_at, :null =>false ,:comment => "最終更新日時"
      t.string :updated_uid, :limit =>16, :null =>false ,:comment => "更新者ID"
      t.datetime :deleted_at ,:comment => "削除日時"
      t.string :deleted_uid, :limit =>16 ,:comment => "削除者ID"
    end
    add_index :lunch_order_locks, [:order_date], :name =>:lunch_order_locks_1
    add_index :lunch_order_locks, [:branche_cd], :name =>:lunch_order_locks_2
  end
end
