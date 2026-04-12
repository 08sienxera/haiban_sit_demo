class CreateVacationBase6Lock < ActiveRecord::Migration[7.1]
  def change
    create_table :vacation_base6_locks,:force => true do |t|
      t.integer :t_year, :limit =>2, :null =>false ,:comment => "対象年"
      t.integer :t_month, :limit =>1, :null =>false ,:comment => "対象月"
      t.string :branche_cd, :limit =>8 ,:comment => "対象グループCD"
      t.integer :lock_flg, :limit =>1 ,:comment => "ロックフラグ"

      t.integer :lock_version, :default=>1 ,:comment => "ロックバージョン"
      t.datetime :created_at, :null =>false ,:comment => "作成日時"
      t.string :created_uid, :limit =>16, :null =>false ,:comment => "新規登録者ID"
      t.datetime :updated_at, :null =>false ,:comment => "最終更新日時"
      t.string :updated_uid, :limit =>16, :null =>false ,:comment => "更新者ID"
      t.datetime :deleted_at ,:comment => "削除日時"
      t.string :deleted_uid, :limit =>16 ,:comment => "削除者ID"
    end

    add_index :vacation_base6_locks, [:t_year,:t_month,:branche_cd], :name =>:vacation_base6_lock_1

  end
end
