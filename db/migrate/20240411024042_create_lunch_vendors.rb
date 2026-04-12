class CreateLunchVendors < ActiveRecord::Migration[7.1]
  def change
    create_table :lunch_vendors do |t|
      t.string :name, :limit =>32, :null =>false ,:comment => "名称"
      t.integer :wh_flg, :limit =>1, :default=>0 ,:comment => "利用種別"
      t.integer :desp_index ,:comment => "表示順"

      t.integer :lock_version, :default=>1 ,:comment => "ロックバージョン"
      t.datetime :created_at, :null =>false ,:comment => "作成日時"
      t.string :created_uid, :limit =>16, :null =>false ,:comment => "新規登録者ID"
      t.datetime :updated_at, :null =>false ,:comment => "最終更新日時"
      t.string :updated_uid, :limit =>16, :null =>false ,:comment => "更新者ID"
      t.datetime :deleted_at ,:comment => "削除日時"
      t.string :deleted_uid, :limit =>16 ,:comment => "削除者ID"
    end
  end
end
