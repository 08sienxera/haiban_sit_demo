class CreateCargoClassMasters < ActiveRecord::Migration[7.1]
  def change
    create_table :cargo_class_masters do |t|
      t.string :cargo_class, :limit =>2 ,:comment => "貨物分類"
      t.string :name, :limit =>64 ,:comment => "分類名称"
      t.string :name_s, :limit =>64 ,:comment => "分類略称"

      t.integer :lock_version, :default=>1 ,:comment => "ロックバージョン"
      t.datetime :created_at, :null =>false ,:comment => "作成日時"
      t.string :created_uid, :limit =>16, :null =>false ,:comment => "新規登録者ID"
      t.datetime :updated_at, :null =>false ,:comment => "最終更新日時"
      t.string :updated_uid, :limit =>16, :null =>false ,:comment => "更新者ID"
      t.datetime :deleted_at ,:comment => "削除日時"
      t.string :deleted_uid, :limit =>16 ,:comment => "削除者ID"
    end
    add_index :cargo_class_masters, [:cargo_class], :name =>:cargo_class_masters_1 ,:unique => true
  end
end
