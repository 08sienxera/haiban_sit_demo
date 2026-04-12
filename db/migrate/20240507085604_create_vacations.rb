class CreateVacations < ActiveRecord::Migration[7.1]
  def change
    create_table :vacations do |t|
      t.integer :user_id, :null =>false ,:comment => "申請者"
      t.string :login_id, :limit =>16, :null =>false ,:comment => "申請者従業員No"
      t.string :branch_cd, :limit =>8 ,:comment => "所属CD"
      t.date :vacation_day, :null =>false ,:comment => "休暇日"
      t.integer :vacation_type_id, :null =>false ,:comment => "休暇種別"
      t.integer :base_no, :null =>false ,:comment => "休暇種別(勤怠ID)"
      t.integer :at_work, :limit =>1 ,:comment => "休日対応可否"
      t.datetime :app_at ,:comment => "申請日時"
      t.integer :sts, :limit =>1 ,:comment => "状態"
      t.integer :authorizer_id ,:comment => "承認者"
      t.string :authorizer_name, :limit =>64 ,:comment => "承認者名"
      t.datetime :approval_at ,:comment => "承認日"
      t.string :reason, :limit =>1024 ,:comment => "差戻理由"
      t.date :origin_date ,:comment => "振替元休暇日"
      t.integer :vacation_id ,:comment => "振替元休暇申請"
      t.string :leav_time, :limit =>8 ,:comment => "退勤希望時刻"

      t.integer :lock_version, :default=>1 ,:comment => "ロックバージョン"
      t.datetime :created_at, :null =>false ,:comment => "作成日時"
      t.string :created_uid, :limit =>16, :null =>false ,:comment => "新規登録者ID"
      t.datetime :updated_at, :null =>false ,:comment => "最終更新日時"
      t.string :updated_uid, :limit =>16, :null =>false ,:comment => "更新者ID"
      t.datetime :deleted_at ,:comment => "削除日時"
      t.string :deleted_uid, :limit =>16 ,:comment => "削除者ID"
    end
    add_index :vacations, [:user_id,:vacation_day], :name =>:vacations_1 ,:unique => true
    add_index :vacations, [:branch_cd], :name =>:vacations_2
    add_index :vacations, [:sts,:base_no], :name =>:vacations_3
  end
end
