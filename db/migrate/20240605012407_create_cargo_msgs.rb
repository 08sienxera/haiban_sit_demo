class CreateCargoMsgs < ActiveRecord::Migration[7.1]
  def change
    create_table :cargo_msgs,:force => true do |t|
      t.date :work_date, :null =>false ,:comment => "作業日"
      t.string :login_id, :limit =>16, :null =>false ,:comment => "従業員No"
      t.integer :user_id, :null =>false ,:comment => "作業者"
      t.string :msg, :limit =>1024 ,:comment => "メッセージ"
      t.string :created_uname, :limit =>128 ,:comment => "投稿者名"

      t.integer :lock_version, :default=>1 ,:comment => "ロックバージョン"
      t.datetime :created_at, :null =>false ,:comment => "作成日時"
      t.string :created_uid, :limit =>16, :null =>false ,:comment => "新規登録者ID"
      t.datetime :updated_at, :null =>false ,:comment => "最終更新日時"
      t.string :updated_uid, :limit =>16, :null =>false ,:comment => "更新者ID"
      t.datetime :deleted_at ,:comment => "削除日時"
      t.string :deleted_uid, :limit =>16 ,:comment => "削除者ID"
    end
    add_index :cargo_msgs, [:work_date,:login_id], :name =>:cargo_msgs_1 ,:unique => true
    add_index :cargo_msgs, [:work_date,:user_id], :name =>:cargo_msgs_2
  end
end
