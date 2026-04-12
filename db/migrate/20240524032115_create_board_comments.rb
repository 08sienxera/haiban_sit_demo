class CreateBoardComments < ActiveRecord::Migration[7.1]
  def change
    create_table :board_comments,:force => true do |t|
      t.integer :board_id, :null =>false ,:comment => "掲示ID"
      t.integer :comment_no, :null =>false ,:comment => "コメントNo"
      t.integer :user_id, :null =>false ,:comment => "投稿者ID"
      t.text :comment ,:comment => "コメント"

      t.integer :lock_version, :default=>1 ,:comment => "ロックバージョン"
      t.datetime :created_at, :null =>false ,:comment => "作成日時"
      t.string :created_uid, :limit =>16, :null =>false ,:comment => "新規登録者ID"
      t.datetime :updated_at, :null =>false ,:comment => "最終更新日時"
      t.string :updated_uid, :limit =>16, :null =>false ,:comment => "更新者ID"
      t.datetime :deleted_at ,:comment => "削除日時"
      t.string :deleted_uid, :limit =>16 ,:comment => "削除者ID"
    end
    add_index :board_comments, [:board_id], :name =>:board_comments_1
  end
end
