class CreateUserAuths < ActiveRecord::Migration[7.1]
  def change
    create_table :user_auths do |t|
      t.string :login_id, :limit =>16, :null =>false ,:comment => "従業員No"
      t.integer :view_boards, :limit =>1, :default=>0 ,:comment => "掲示表示"
      t.integer :lunch_orders, :limit =>1, :default=>0 ,:comment => "昼食集計"
      t.integer :boards, :limit =>1, :default=>0 ,:comment => "掲示管理"
      t.integer :vacations, :limit =>1, :default=>0 ,:comment => "休暇管理"
      t.integer :result_assignment, :limit =>1, :default=>0 ,:comment => "配番実績"
      t.integer :cargo_requests, :limit =>1, :default=>0 ,:comment => "作業依頼"
      t.integer :cargos, :limit =>1, :default=>0 ,:comment => "荷役予定"
      t.integer :wk_assignment, :limit =>1, :default=>0 ,:comment => "配番"
      t.integer :sagyo_request, :limit =>1, :default=>0 ,:comment => "作業依頼書"
      t.integer :cargo_request_head_count, :limit =>1, :default=>0 ,:comment => "必要人数表"
      t.integer :cargo_head_count, :limit =>1, :default=>0 ,:comment => "配番人数表"
      t.integer :cargo_worker_schedule, :limit =>1, :default=>0 ,:comment => "荷役作業員予定表"
      t.integer :cargo_schedule, :limit =>1, :default=>0 ,:comment => "配番表（予定"
      t.integer :time_sheet, :limit =>1, :default=>0 ,:comment => "出勤時間表"
      t.integer :work_daily_sheet, :limit =>1, :default=>0 ,:comment => "出欠日報・残業届"
      t.integer :time_card, :limit =>1, :default=>0 ,:comment => "タイムカードデータ"
      t.integer :cargo_result, :limit =>1, :default=>0 ,:comment => "配番表(実績)"
      t.integer :sagyo_haiban, :limit =>1, :default=>0 ,:comment => "荷役実績"
      t.integer :daily_cargo_work_result, :limit =>1, :default=>0 ,:comment => "日別荷役作業実績出力"
      t.integer :monthly_cargo_work_result, :limit =>1, :default=>0 ,:comment => "荷役作業実績表出力"
      t.integer :tax_free_machines_pdf, :limit =>1, :default=>0 ,:comment => "免税軽油稼働実績表出力"
      t.integer :cargo_worker_result, :limit =>1, :default=>0 ,:comment => "荷役作業員実績表出力"
      t.integer :lunch_summary, :limit =>1, :default=>0 ,:comment => "昼食集計帳票出力"
      t.integer :work_time_summary, :limit =>1, :default=>0 ,:comment => "現業職労働時間・時間外管理表出力"
      t.integer :cargo_work_detail, :limit =>1, :default=>0 ,:comment => "荷役作業明細一覧出力"
      t.integer :worker_work_summary, :limit =>1, :default=>0 ,:comment => "作業員毎作業一覧出力"

      t.integer :lock_version, :default=>1 ,:comment => "ロックバージョン"
      t.datetime :created_at, :null =>false ,:comment => "作成日時"
      t.string :created_uid, :limit =>16, :null =>false ,:comment => "新規登録者ID"
      t.datetime :updated_at, :null =>false ,:comment => "最終更新日時"
      t.string :updated_uid, :limit =>16, :null =>false ,:comment => "更新者ID"
      t.datetime :deleted_at ,:comment => "削除日時"
      t.string :deleted_uid, :limit =>16 ,:comment => "削除者ID"
    end
    add_index :user_auths, [:login_id], :name =>:user_auths_1 ,:unique => true
  end
end
