class CreateBoardGroups < ActiveRecord::Migration[7.1]
  def change
    create_table :board_groups do |t|
        t.string :name, :limit =>64, :null =>false ,:comment => "グループ名称"
        t.integer :desp_index ,:comment => "表示順"
        t.string :group_type, :limit =>8 ,:comment => "対象タイプ"
        
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
