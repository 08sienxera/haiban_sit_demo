class CreateWorkTimeSummaries < ActiveRecord::Migration[7.1]
  def change
    create_table :work_time_summaries do |t|
      t.date :work_date, :null =>false ,:comment => "作業日"
      t.string :aggr_flg, :limit =>1, :null =>false ,:comment => "集計対象"
      t.integer :t_id ,:comment => "作業者ID(機械ID)"
      t.string :t_cd, :limit =>16 ,:comment => "従業員No(機械番号)"
      t.time :s_time ,:comment => "開始時刻（出勤時刻"
      t.time :e_time ,:comment => "終了時刻"
      t.integer :bus_flg, :limit =>1 ,:comment => "バスフラグ"
      t.integer :work_class, :limit =>1 ,:comment => "作業区分"
      t.integer :base_no, :default=>1 ,:comment => "登録時休暇申請状況"
      t.integer :work_time ,:comment => "法定作業時間"
      t.integer :orver_time ,:comment => "法定残業時間"
      t.integer :p_work_time ,:comment => "所定作業時間"
      t.integer :p_orver_time ,:comment => "所定残業時間"
      t.integer :p_early_time ,:comment => "所定早出時間"
      t.integer :data_root ,:comment => "データ元"

      t.integer :lock_version, :default=>1 ,:comment => "ロックバージョン"
      t.datetime :created_at, :null =>false ,:comment => "作成日時"
      t.string :created_uid, :limit =>16, :null =>false ,:comment => "新規登録者ID"
      t.datetime :updated_at, :null =>false ,:comment => "最終更新日時"
      t.string :updated_uid, :limit =>16, :null =>false ,:comment => "更新者ID"
      t.datetime :deleted_at ,:comment => "削除日時"
      t.string :deleted_uid, :limit =>16 ,:comment => "削除者ID"
    end
    add_index :work_time_summaries, [:work_date,:aggr_flg,:t_cd], :name =>:work_time_summaries_1 ,:unique => true
    add_index :work_time_summaries, [:t_id], :name =>:work_time_summaries_2
  end
end
