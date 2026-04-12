class CreateMachines < ActiveRecord::Migration[7.1]
  def change
    create_table :machines do |t|
      t.string :cd, :limit =>16, :null =>false ,:comment => "機械番号"
      t.string :name, :limit =>16, :null =>false ,:comment => "機械名"
      t.string :m_type, :limit =>2, :null =>false ,:comment => "機械種別"
      t.string :branch_cd, :limit =>8 ,:comment => "所属CD"
      t.string :color, :limit =>8 ,:comment => "パネル色"
      t.string :a_category, :limit =>1 ,:comment => "実績集計区分"
      t.integer :light_oil, :limit =>1 ,:comment => "免税軽油該当"
      t.integer :maintenance, :limit =>1 ,:comment => "メンテナンス対象"
      t.integer :u_maintenance, :limit =>1 ,:comment => "メンテナンス中"
      t.integer :lock_version, :default=>1 ,:comment => "ロックバージョン"
      t.datetime :created_at, :null =>false ,:comment => "作成日時"
      t.string :created_uid, :limit =>16, :null =>false ,:comment => "新規登録者ID"
      t.datetime :updated_at, :null =>false ,:comment => "最終更新日時"
      t.string :updated_uid, :limit =>16, :null =>false ,:comment => "更新者ID"
      t.datetime :deleted_at ,:comment => "削除日時"
      t.string :deleted_uid, :limit =>16 ,:comment => "削除者ID"
    end
    add_index :machines, [:m_type], :name =>:machines_1
  end
end
