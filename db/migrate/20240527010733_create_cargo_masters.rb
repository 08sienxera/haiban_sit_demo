class CreateCargoMasters < ActiveRecord::Migration[7.1]
  def change
    create_table :cargo_masters,:force => true do |t|
      t.string :move_no, :limit =>16 ,:comment => "動静番号"
      t.string :work_name, :limit =>128 ,:comment => "作業名"
      t.string :work_place, :limit =>32 ,:comment => "場所"
      t.string :aggregate_category, :limit =>1 ,:comment => "事業区分"
      t.string :cargo_class, :limit =>2 ,:comment => "集計貨物分類"

      t.integer :lock_version, :default=>1 ,:comment => "ロックバージョン"
      t.datetime :created_at, :null =>false ,:comment => "作成日時"
      t.string :created_uid, :limit =>16, :null =>false ,:comment => "新規登録者ID"
      t.datetime :updated_at, :null =>false ,:comment => "最終更新日時"
      t.string :updated_uid, :limit =>16, :null =>false ,:comment => "更新者ID"
      t.datetime :deleted_at ,:comment => "削除日時"
      t.string :deleted_uid, :limit =>16 ,:comment => "削除者ID"
    end
    add_index :cargo_masters, [:move_no], :name =>:cargo_masters_1 ,:unique => true
  end
end
