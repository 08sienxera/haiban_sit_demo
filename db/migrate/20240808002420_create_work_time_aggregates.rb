class CreateWorkTimeAggregates < ActiveRecord::Migration[7.1]
  def change
    create_table :work_time_aggregates do |t|
      t.integer :t_year, :limit =>2, :null =>false ,:comment => "集計年"
      t.integer :t_month, :limit =>1, :null =>false ,:comment => "集計月"
      t.string :aggr_flg, :limit =>1, :null =>false ,:comment => "集計対象"
      t.integer :t_id ,:comment => "作業者ID(機械ID)"
      t.string :t_cd, :limit =>16 ,:comment => "従業員No(機械番号)"
      t.integer :work_time, :default=>0 ,:comment => "法定作業時間(月合計"
      t.integer :orver_time, :default=>0 ,:comment => "法定残業時間(月合計"
      t.integer :l_ot_wd, :default=>0 ,:comment => "法定要素（休日労働時間）"
      t.integer :l_ot_45, :default=>0 ,:comment => "法定(45)"
      t.integer :l_ot_80, :default=>0 ,:comment => "法定(80)"
      t.integer :p_work_time, :default=>0 ,:comment => "所定作業時間(月合計"
      t.integer :p_orver_time, :default=>0 ,:comment => "所定残業時間(月合計"
      t.integer :p_early_time, :default=>0 ,:comment => "所定早出時間(月合計"
      t.integer :wd_base6_num, :limit =>1, :default=>0 ,:comment => "平日公休出勤数(月合計"
      t.integer :hd_base6_num, :limit =>1, :default=>0 ,:comment => "日曜公休出勤数(月合計"

      t.integer :lock_version, :default=>1 ,:comment => "ロックバージョン"
      t.datetime :created_at, :null =>false ,:comment => "作成日時"
      t.string :created_uid, :limit =>16, :null =>false ,:comment => "新規登録者ID"
      t.datetime :updated_at, :null =>false ,:comment => "最終更新日時"
      t.string :updated_uid, :limit =>16, :null =>false ,:comment => "更新者ID"
      t.datetime :deleted_at ,:comment => "削除日時"
      t.string :deleted_uid, :limit =>16 ,:comment => "削除者ID"
    end
    add_index :work_time_aggregates, [:t_year,:t_month,:aggr_flg,:t_cd], :name =>:work_time_aggregates_1
    add_index :work_time_aggregates, [:t_id], :name =>:work_time_aggregates_2
  end
end
