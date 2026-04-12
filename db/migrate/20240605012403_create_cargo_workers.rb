class CreateCargoWorkers < ActiveRecord::Migration[7.1]
  def change
    create_table :cargo_workers,:force => true do |t|
      t.integer :cargo_id, :null =>false ,:comment => "作業"
      t.date :work_date, :null =>false ,:comment => "作業日"
      t.integer :user_id, :null =>false ,:comment => "作業者"
      t.string :login_id, :limit =>16, :null =>false ,:comment => "従業員No"
      t.string :wk_type, :limit =>2, :null =>false ,:comment => "作業カテゴリ"
      t.integer :wk_index, :limit =>1, :null =>false ,:comment => "順序"
      t.string :wk_class, :limit =>8 ,:comment => "担当作業"
      t.integer :competence, :limit =>1 ,:comment => "力量"
      t.integer :work_time ,:comment => "作業時間"
      t.integer :orver_time ,:comment => "残業時間"
      t.integer :lock_flg, :limit =>1 ,:comment => "ロック"

      t.integer :lock_version, :default=>1 ,:comment => "ロックバージョン"
      t.datetime :created_at, :null =>false ,:comment => "作成日時"
      t.string :created_uid, :limit =>16, :null =>false ,:comment => "新規登録者ID"
      t.datetime :updated_at, :null =>false ,:comment => "最終更新日時"
      t.string :updated_uid, :limit =>16, :null =>false ,:comment => "更新者ID"
      t.datetime :deleted_at ,:comment => "削除日時"
      t.string :deleted_uid, :limit =>16 ,:comment => "削除者ID"
    end
    add_index :cargo_workers, [:cargo_id], :name =>:cargo_workers_1
    add_index :cargo_workers, [:work_date], :name =>:cargo_workers_2
    add_index :cargo_workers, [:user_id], :name =>:cargo_workers_3
    add_index :cargo_workers, [:login_id], :name =>:cargo_workers_4
  end
end
