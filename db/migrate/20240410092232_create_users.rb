class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :login_id, :limit =>16, :null =>false ,:comment => "従業員No"
      t.string :name, :limit =>64, :null =>false ,:comment => "従業員氏名"
      t.string :password, :limit =>32, :null =>false ,:comment => "パスワード"
      t.integer :bbs_max_count, :limit =>1 ,:comment => "新着掲示件数"
      t.integer :bbs_mail_flg, :limit =>1 ,:comment => "掲示メール受信設定"
      t.integer :holiday_mail_flg, :limit =>1 ,:comment => "休暇申請リマインドメール受信設定"
      t.string :mail ,:comment => "メールアドレス"
      t.string :tel ,:comment => "電話番号"
      t.integer :auth_flg, :limit =>1 ,:comment => "権限フラグ"

      t.integer :lock_version, :default=>1 ,:comment => "ロックバージョン"
      t.datetime :created_at, :null =>false ,:comment => "作成日時"
      t.string :created_uid, :limit =>16, :null =>false ,:comment => "新規登録者ID"
      t.datetime :updated_at, :null =>false ,:comment => "最終更新日時"
      t.string :updated_uid, :limit =>16, :null =>false ,:comment => "更新者ID"
      t.datetime :deleted_at ,:comment => "削除日時"
      t.string :deleted_uid, :limit =>16 ,:comment => "削除者ID"
    end
    add_index :users, [:login_id], :name =>:users_1 ,:unique => true
  end
end
