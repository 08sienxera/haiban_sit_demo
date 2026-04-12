class CreateBranches < ActiveRecord::Migration[7.1]
  def change
    create_table :branches do |t|
      t.date :applicable, :null =>false ,:comment => "改定日"
      t.string :cd, :limit =>8, :null =>false ,:comment => "CD"
      t.string :name, :limit =>32, :null =>false ,:comment => "名称"
      t.string :color, :limit =>8 ,:comment => "色"
      t.integer :desp_index ,:comment => "表示順"

      t.integer :lock_version, :default=>1 ,:comment => "ロックバージョン"
      t.datetime :created_at, :null =>false ,:comment => "作成日時"
      t.string :created_uid, :limit =>16, :null =>false ,:comment => "新規登録者ID"
      t.datetime :updated_at, :null =>false ,:comment => "最終更新日時"
      t.string :updated_uid, :limit =>16, :null =>false ,:comment => "更新者ID"
      t.datetime :deleted_at ,:comment => "削除日時"
      t.string :deleted_uid, :limit =>16 ,:comment => "削除者ID"
    end
    add_index :branches, [:applicable,:cd], :name =>:branches_1 ,:unique => true
  end
end
