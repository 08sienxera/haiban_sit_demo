class CreateBoards < ActiveRecord::Migration[7.1]
  def change
    create_table :boards,:force => true do |t|
      t.integer :important_flg, :limit =>1 ,:comment => "重要フラグ"
      t.integer :mail_send, :limit =>1 ,:comment => "メール通知有無"
      t.integer :board_group_id, :null =>false ,:comment => "公開対象"
      t.datetime :view_s_dt, :null =>false ,:comment => "掲示期間（開始）"
      t.integer :view_e_infin, :limit =>1 ,:comment => "掲示期間（無期限）"
      t.datetime :view_e_dt ,:comment => "掲示期間（終了）"
      t.integer :board_category_id, :null =>false ,:comment => "カテゴリ"
      t.string :subject ,:comment => "件名"
      t.text :body1 ,:comment => "前文"
      t.string :file_name ,:comment => "添付ファイル"
      t.text :body2 ,:comment => "後文"
      t.integer :target_count, :default=>0 ,:comment => "対象者数"
      t.integer :confirmation_count, :default=>0 ,:comment => "閲覧者数"
      t.integer :comment_count, :default=>0 ,:comment => "コメント数"

      t.integer :lock_version, :default=>1 ,:comment => "ロックバージョン"
      t.datetime :created_at, :null =>false ,:comment => "作成日時"
      t.string :created_uid, :limit =>16, :null =>false ,:comment => "新規登録者ID"
      t.datetime :updated_at, :null =>false ,:comment => "最終更新日時"
      t.string :updated_uid, :limit =>16, :null =>false ,:comment => "更新者ID"
      t.datetime :deleted_at ,:comment => "削除日時"
      t.string :deleted_uid, :limit =>16 ,:comment => "削除者ID"
    end
    add_index :boards, [:view_s_dt], :name =>:boards_1
    add_index :boards, [:view_e_dt], :name =>:boards_2
    add_index :boards, [:subject], :name =>:boards_3
  end
end
