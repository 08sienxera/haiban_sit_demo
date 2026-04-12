class CreateWokers < ActiveRecord::Migration[7.1]
  def change
    create_table :wokers do |t|
      t.date :applicable, :null =>false ,:comment => "改定日"
      t.string :login_id, :limit =>16, :null =>false ,:comment => "従業員No"
      t.string :s_name, :limit =>16, :null =>false ,:comment => "パネル表示名"
      t.string :branch_cd, :limit =>8 ,:comment => "グループCD"
      t.integer :competence_fm, :limit =>1 ,:comment => "FM"
      t.integer :competence_dm, :limit =>1 ,:comment => "DM"
      t.integer :competence_wm, :limit =>1 ,:comment => "WM"
      t.integer :competence_cr, :limit =>1 ,:comment => "クレーン"
      t.integer :competence_ld, :limit =>1 ,:comment => "ローダ"
      t.integer :competence_bh, :limit =>1 ,:comment => "バックホー"
      t.integer :competence_sl, :limit =>1 ,:comment => "船内ローダ"
      t.integer :competence_bl, :limit =>1 ,:comment => "ブル"
      t.integer :competence_lf, :limit =>1 ,:comment => "リフト"
      t.integer :competence_sc, :limit =>1 ,:comment => "SC"
      t.integer :competence_ot, :limit =>1 ,:comment => "他取扱"
      t.integer :competence_dv, :limit =>1 ,:comment => "運転"
      t.integer :competence_wk, :limit =>1 ,:comment => "作業"
      t.integer :desp_index ,:comment => "表示順"

      t.integer :lock_version, :default=>1 ,:comment => "ロックバージョン"
      t.datetime :created_at, :null =>false ,:comment => "作成日時"
      t.string :created_uid, :limit =>16, :null =>false ,:comment => "新規登録者ID"
      t.datetime :updated_at, :null =>false ,:comment => "最終更新日時"
      t.string :updated_uid, :limit =>16, :null =>false ,:comment => "更新者ID"
      t.datetime :deleted_at ,:comment => "削除日時"
      t.string :deleted_uid, :limit =>16 ,:comment => "削除者ID"
    end
    add_index :wokers, [:applicable,:login_id], :name =>:wokers_1 ,:unique => true
  end
end
