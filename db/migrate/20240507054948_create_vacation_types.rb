class CreateVacationTypes < ActiveRecord::Migration[7.1]
  def change
    create_table :vacation_types do |t|

      t.integer :base_no, :null =>false ,:comment => "勤怠ID(既存システム連携用）"
      t.string :cd , :null =>false ,:comment => "勤怠コード"
      t.string :name ,:comment => "配番用表記"
      t.string :assign_name ,:comment => "配番表用表記"
      t.string :time_sheet_name ,:comment => "出勤時間表用表記"

      t.integer :lock_version, :default=>1 ,:comment => "ロックバージョン"
      t.datetime :created_at, :null =>false ,:comment => "作成日時"
      t.string :created_uid, :limit =>16, :null =>false ,:comment => "新規登録者ID"
      t.datetime :updated_at, :null =>false ,:comment => "最終更新日時"
      t.string :updated_uid, :limit =>16, :null =>false ,:comment => "更新者ID"
      t.datetime :deleted_at ,:comment => "削除日時"
      t.string :deleted_uid, :limit =>16 ,:comment => "削除者ID"

    end
  end
end
