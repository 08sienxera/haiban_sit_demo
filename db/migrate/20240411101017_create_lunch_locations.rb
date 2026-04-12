class CreateLunchLocations < ActiveRecord::Migration[7.1]
  def change
    create_table :lunch_locations,:force => true do |t|
      t.string :s_name, :limit =>32, :null =>false ,:comment => "略称"
      t.string :name, :limit =>64, :null =>false ,:comment => "名称"
      t.string :note ,:comment => "注意条項"
      t.integer :desp_index, :null =>false ,:comment => "表示順"
      t.text :cargo_key_wd ,:comment => "配番連携キーワード"

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
