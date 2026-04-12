class CreateWhCalendars < ActiveRecord::Migration[7.1]
  def change
    create_table :wh_calendars,:force => true do |t|
      t.date :t_date, :null =>false ,:comment => "日付"
      t.integer :wh_flg, :limit =>1, :default=>0 ,:comment => "平日／公休日フラグ"
      t.integer :lunch_vendor_id ,:comment => "昼食注文先"
      t.integer :ph_max, :limit =>1 ,:comment => "平日公休出勤上限数"

      t.integer :lock_version, :default=>1 ,:comment => "ロックバージョン"
      t.datetime :created_at, :null =>false ,:comment => "作成日時"
      t.string :created_uid, :limit =>16, :null =>false ,:comment => "新規登録者ID"
      t.datetime :updated_at, :null =>false ,:comment => "最終更新日時"
      t.string :updated_uid, :limit =>16, :null =>false ,:comment => "更新者ID"
      t.datetime :deleted_at ,:comment => "削除日時"
      t.string :deleted_uid, :limit =>16 ,:comment => "削除者ID"
    end
    add_index :wh_calendars, [:t_date], :name =>:wh_calendars_1 ,:unique => true
  end
end
