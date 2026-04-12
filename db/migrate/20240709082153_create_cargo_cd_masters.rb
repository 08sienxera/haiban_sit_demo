class CreateCargoCdMasters < ActiveRecord::Migration[7.1]
  def change
    create_table :cargo_cd_masters do |t|
      t.string :work_cd, :limit =>4 ,:comment => "貨物コード"
      t.string :cargo_class, :limit =>2 ,:comment => "貨物分類"
      t.string :cargo_class2, :limit =>8 ,:comment => "貨物分類2"
      t.string :cargo_class3, :limit =>8 ,:comment => "貨物分類3"
      t.string :cargo_class4, :limit =>8 ,:comment => "貨物分類4"
      t.string :cargo_class5, :limit =>8 ,:comment => "貨物分類5"
      t.string :cargo_class6, :limit =>8 ,:comment => "貨物分類6"
      t.string :cargo_class7, :limit =>8 ,:comment => "貨物分類7"
      t.string :cargo_class8, :limit =>8 ,:comment => "貨物分類8"
      t.string :cargo_class9, :limit =>8 ,:comment => "貨物分類9"
      t.string :cargo_name, :limit =>64 ,:comment => "貨物名称"
      t.string :cargo_name_s, :limit =>32 ,:comment => "貨物略称"
      t.string :zenno_cd ,:comment => "全農CD"
      t.string :zenno_name, :limit =>64 ,:comment => "全農管理品目"
      t.string :cargo_class11, :limit =>4 ,:comment => "肥料区分"
      t.string :cargo_class12, :limit =>4 ,:comment => "木材種別"

      t.integer :lock_version, :default=>1 ,:comment => "ロックバージョン"
      t.datetime :created_at, :null =>false ,:comment => "作成日時"
      t.string :created_uid, :limit =>16, :null =>false ,:comment => "新規登録者ID"
      t.datetime :updated_at, :null =>false ,:comment => "最終更新日時"
      t.string :updated_uid, :limit =>16, :null =>false ,:comment => "更新者ID"
      t.datetime :deleted_at ,:comment => "削除日時"
      t.string :deleted_uid, :limit =>16 ,:comment => "削除者ID"
    end
    add_index :cargo_cd_masters, [:work_cd], :name =>:cargo_cd_masters_1 ,:unique => true
  end
end
