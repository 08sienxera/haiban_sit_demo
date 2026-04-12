class CreateLunchOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :lunch_orders do |t|
      t.date :order_date, :null =>false ,:comment => "注文日"
      t.integer :user_id, :null =>false ,:comment => "注文者ID"
      t.string :branche_cd, :limit =>8 ,:comment => "注文者グループCD"
      t.integer :lunch_location_id, :null =>false ,:comment => "昼食配送先"
      t.integer :lunch_vendor_id, :null =>false ,:comment => "昼食注文先"
      t.integer :lunch_menu_id, :null =>false ,:comment => "昼食メニュー"
      t.integer :order_num, :limit =>1, :null =>false, :default=>1 ,:comment => "注文数"
      t.integer :lock_version, :default=>1 ,:comment => "ロックバージョン"

      t.datetime :created_at, :null =>false ,:comment => "作成日時"
      t.string :created_uid, :limit =>16, :null =>false ,:comment => "新規登録者ID"
      t.datetime :updated_at, :null =>false ,:comment => "最終更新日時"
      t.string :updated_uid, :limit =>16, :null =>false ,:comment => "更新者ID"
      t.datetime :deleted_at ,:comment => "削除日時"
      t.string :deleted_uid, :limit =>16 ,:comment => "削除者ID"
    end
    add_index :lunch_orders, [:order_date], :name =>:lunch_orders_1
    add_index :lunch_orders, [:user_id], :name =>:lunch_orders_2
  end
end
