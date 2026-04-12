class CreateWhSummary < ActiveRecord::Migration[7.1]
  def change
    create_table :wh_summaries do |t|
      t.integer :t_year, :limit =>2, :null =>false ,:comment => "対象年"
      t.integer :t_month, :limit =>1, :null =>false ,:comment => "対象月"
      t.date :s_date, :null =>false ,:comment => "開始日"
      t.date :e_date, :null =>false ,:comment => "終了日"
      t.date :cs_date ,:comment => "カレンダー開始日"
      t.date :ce_date ,:comment => "カレンダー終了日"
      t.integer :sunday_num, :limit =>1 ,:comment => "日曜日数"
      t.integer :holiday_num, :limit =>1 ,:comment => "祝祭日数"
      t.integer :h_setting_min, :limit =>1 ,:comment => "公休日設定下限"

      t.integer :lock_version, :default=>1 ,:comment => "ロックバージョン"
      t.datetime :created_at, :null =>false ,:comment => "作成日時"
      t.string :created_uid, :limit =>16, :null =>false ,:comment => "新規登録者ID"
      t.datetime :updated_at, :null =>false ,:comment => "最終更新日時"
      t.string :updated_uid, :limit =>16, :null =>false ,:comment => "更新者ID"
      t.datetime :deleted_at ,:comment => "削除日時"
      t.string :deleted_uid, :limit =>16 ,:comment => "削除者ID"
    end
    add_index :wh_summaries, [:t_year,:t_month], :name =>:wh_summaries_1 ,:unique => true
  end
end
