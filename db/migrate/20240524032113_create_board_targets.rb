class CreateBoardTargets < ActiveRecord::Migration[7.1]
  def change
    create_table :board_targets,:force => true do |t|
      t.integer :board_id, :null =>false ,:comment => "掲示ID"
      t.integer :user_id, :null =>false ,:comment => "ユーザ"
      t.string :login_id, :limit =>16, :null =>false ,:comment => "従業員No"
      t.string :branche_cd, :limit =>8 ,:comment => "所属CD"
      t.datetime :confirmation_m_at ,:comment => "本文確認"
      t.datetime :confirmation_s_at ,:comment => "コメント確認"

      t.integer :lock_version, :default=>1 ,:comment => "ロックバージョン"
      t.datetime :created_at, :null =>false ,:comment => "作成日時"
      t.string :created_uid, :limit =>16, :null =>false ,:comment => "新規登録者ID"
      t.datetime :updated_at, :null =>false ,:comment => "最終更新日時"
      t.string :updated_uid, :limit =>16, :null =>false ,:comment => "更新者ID"
      t.datetime :deleted_at ,:comment => "削除日時"
      t.string :deleted_uid, :limit =>16 ,:comment => "削除者ID"
    end
    add_index :board_targets, [:board_id], :name =>:board_targets_1
    add_index :board_targets, [:login_id], :name =>:board_targets_2
  end
end
