# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_11_13_035643) do
  create_table "applicables", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "section", limit: 1, null: false, comment: "区分"
    t.date "applicable", null: false, comment: "改定日"
    t.integer "lock_version", default: 1, comment: "ロックバージョン"
    t.datetime "created_at", null: false, comment: "作成日時"
    t.string "created_uid", limit: 16, null: false, comment: "新規登録者ID"
    t.datetime "updated_at", null: false, comment: "最終更新日時"
    t.string "updated_uid", limit: 16, null: false, comment: "更新者ID"
    t.datetime "deleted_at", comment: "削除日時"
    t.string "deleted_uid", limit: 16, comment: "削除者ID"
    t.index ["section", "applicable"], name: "applicables_1", unique: true
  end

  create_table "board_categories", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", limit: 64, null: false, comment: "名称"
    t.integer "desp_index", comment: "表示順"
    t.integer "lock_version", default: 1, comment: "ロックバージョン"
    t.datetime "created_at", null: false, comment: "作成日時"
    t.string "created_uid", limit: 16, null: false, comment: "新規登録者ID"
    t.datetime "updated_at", null: false, comment: "最終更新日時"
    t.string "updated_uid", limit: 16, null: false, comment: "更新者ID"
    t.datetime "deleted_at", comment: "削除日時"
    t.string "deleted_uid", limit: 16, comment: "削除者ID"
  end

  create_table "board_comments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "board_id", null: false, comment: "掲示ID"
    t.integer "comment_no", null: false, comment: "コメントNo"
    t.integer "user_id", null: false, comment: "投稿者ID"
    t.text "comment", comment: "コメント"
    t.integer "lock_version", default: 1, comment: "ロックバージョン"
    t.datetime "created_at", null: false, comment: "作成日時"
    t.string "created_uid", limit: 16, null: false, comment: "新規登録者ID"
    t.datetime "updated_at", null: false, comment: "最終更新日時"
    t.string "updated_uid", limit: 16, null: false, comment: "更新者ID"
    t.datetime "deleted_at", comment: "削除日時"
    t.string "deleted_uid", limit: 16, comment: "削除者ID"
    t.index ["board_id"], name: "board_comments_1"
  end

  create_table "board_group_wokers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "board_group_id", null: false, comment: "公開対象グループ"
    t.string "login_id", limit: 16, null: false, comment: "従業員No"
    t.integer "lock_version", default: 1, comment: "ロックバージョン"
    t.datetime "created_at", null: false, comment: "作成日時"
    t.string "created_uid", limit: 16, null: false, comment: "新規登録者ID"
    t.datetime "updated_at", null: false, comment: "最終更新日時"
    t.string "updated_uid", limit: 16, null: false, comment: "更新者ID"
    t.datetime "deleted_at", comment: "削除日時"
    t.string "deleted_uid", limit: 16, comment: "削除者ID"
    t.index ["board_group_id"], name: "board_group_wokers_1"
  end

  create_table "board_groups", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", limit: 64, null: false, comment: "グループ名称"
    t.integer "desp_index", comment: "表示順"
    t.string "group_type", limit: 8, comment: "対象タイプ"
    t.integer "lock_version", default: 1, comment: "ロックバージョン"
    t.datetime "created_at", null: false, comment: "作成日時"
    t.string "created_uid", limit: 16, null: false, comment: "新規登録者ID"
    t.datetime "updated_at", null: false, comment: "最終更新日時"
    t.string "updated_uid", limit: 16, null: false, comment: "更新者ID"
    t.datetime "deleted_at", comment: "削除日時"
    t.string "deleted_uid", limit: 16, comment: "削除者ID"
  end

  create_table "board_targets", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "board_id", null: false, comment: "掲示ID"
    t.integer "user_id", null: false, comment: "ユーザ"
    t.string "login_id", limit: 16, null: false, comment: "従業員No"
    t.string "branche_cd", limit: 8, comment: "所属CD"
    t.datetime "confirmation_m_at", comment: "本文確認"
    t.datetime "confirmation_s_at", comment: "コメント確認"
    t.integer "lock_version", default: 1, comment: "ロックバージョン"
    t.datetime "created_at", null: false, comment: "作成日時"
    t.string "created_uid", limit: 16, null: false, comment: "新規登録者ID"
    t.datetime "updated_at", null: false, comment: "最終更新日時"
    t.string "updated_uid", limit: 16, null: false, comment: "更新者ID"
    t.datetime "deleted_at", comment: "削除日時"
    t.string "deleted_uid", limit: 16, comment: "削除者ID"
    t.index ["board_id"], name: "board_targets_1"
    t.index ["login_id"], name: "board_targets_2"
  end

  create_table "boards", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "important_flg", limit: 1, comment: "重要フラグ"
    t.integer "mail_send", limit: 1, comment: "メール通知有無"
    t.integer "board_group_id", null: false, comment: "公開対象"
    t.datetime "view_s_dt", null: false, comment: "掲示期間（開始）"
    t.integer "view_e_infin", limit: 1, comment: "掲示期間（無期限）"
    t.datetime "view_e_dt", comment: "掲示期間（終了）"
    t.integer "board_category_id", null: false, comment: "カテゴリ"
    t.string "subject", comment: "件名"
    t.text "body1", comment: "前文"
    t.string "file_name", comment: "添付ファイル"
    t.text "body2", comment: "後文"
    t.integer "target_count", default: 0, comment: "対象者数"
    t.integer "confirmation_count", default: 0, comment: "閲覧者数"
    t.integer "comment_count", default: 0, comment: "コメント数"
    t.integer "lock_version", default: 1, comment: "ロックバージョン"
    t.datetime "created_at", null: false, comment: "作成日時"
    t.string "created_uid", limit: 16, null: false, comment: "新規登録者ID"
    t.datetime "updated_at", null: false, comment: "最終更新日時"
    t.string "updated_uid", limit: 16, null: false, comment: "更新者ID"
    t.datetime "deleted_at", comment: "削除日時"
    t.string "deleted_uid", limit: 16, comment: "削除者ID"
    t.string "file_name2", comment: "添付ファイル２"
    t.string "file_name3", comment: "添付ファイル３"
    t.string "file_name4", comment: "添付ファイル４"
    t.string "file_name5", comment: "添付ファイル５"
    t.index ["subject"], name: "boards_3"
    t.index ["view_e_dt"], name: "boards_2"
    t.index ["view_s_dt"], name: "boards_1"
  end

  create_table "branches", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.date "applicable", null: false, comment: "改定日"
    t.string "cd", limit: 8, null: false, comment: "CD"
    t.string "name", limit: 32, null: false, comment: "名称"
    t.string "color", limit: 8, comment: "色"
    t.integer "desp_index", comment: "表示順"
    t.integer "lock_version", default: 1, comment: "ロックバージョン"
    t.datetime "created_at", null: false, comment: "作成日時"
    t.string "created_uid", limit: 16, null: false, comment: "新規登録者ID"
    t.datetime "updated_at", null: false, comment: "最終更新日時"
    t.string "updated_uid", limit: 16, null: false, comment: "更新者ID"
    t.datetime "deleted_at", comment: "削除日時"
    t.string "deleted_uid", limit: 16, comment: "削除者ID"
    t.index ["applicable", "cd"], name: "branches_1", unique: true
  end

  create_table "cargo_cd_masters", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "work_cd", limit: 4, comment: "貨物コード"
    t.string "cargo_class", limit: 2, comment: "貨物分類"
    t.string "cargo_class2", limit: 8, comment: "貨物分類2"
    t.string "cargo_class3", limit: 8, comment: "貨物分類3"
    t.string "cargo_class4", limit: 8, comment: "貨物分類4"
    t.string "cargo_class5", limit: 8, comment: "貨物分類5"
    t.string "cargo_class6", limit: 8, comment: "貨物分類6"
    t.string "cargo_class7", limit: 8, comment: "貨物分類7"
    t.string "cargo_class8", limit: 8, comment: "貨物分類8"
    t.string "cargo_class9", limit: 8, comment: "貨物分類9"
    t.string "cargo_name", limit: 64, comment: "貨物名称"
    t.string "cargo_name_s", limit: 32, comment: "貨物略称"
    t.string "zenno_cd", comment: "全農CD"
    t.string "zenno_name", limit: 64, comment: "全農管理品目"
    t.string "cargo_class11", limit: 4, comment: "肥料区分"
    t.string "cargo_class12", limit: 4, comment: "木材種別"
    t.integer "lock_version", default: 1, comment: "ロックバージョン"
    t.datetime "created_at", null: false, comment: "作成日時"
    t.string "created_uid", limit: 16, null: false, comment: "新規登録者ID"
    t.datetime "updated_at", null: false, comment: "最終更新日時"
    t.string "updated_uid", limit: 16, null: false, comment: "更新者ID"
    t.datetime "deleted_at", comment: "削除日時"
    t.string "deleted_uid", limit: 16, comment: "削除者ID"
    t.index ["work_cd"], name: "cargo_cd_masters_1", unique: true
  end

  create_table "cargo_class_masters", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "cargo_class", limit: 2, comment: "貨物分類"
    t.string "name", limit: 64, comment: "分類名称"
    t.string "name_s", limit: 64, comment: "分類略称"
    t.integer "lock_version", default: 1, comment: "ロックバージョン"
    t.datetime "created_at", null: false, comment: "作成日時"
    t.string "created_uid", limit: 16, null: false, comment: "新規登録者ID"
    t.datetime "updated_at", null: false, comment: "最終更新日時"
    t.string "updated_uid", limit: 16, null: false, comment: "更新者ID"
    t.datetime "deleted_at", comment: "削除日時"
    t.string "deleted_uid", limit: 16, comment: "削除者ID"
    t.index ["cargo_class"], name: "cargo_class_masters_1", unique: true
  end

  create_table "cargo_machines", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "cargo_id", null: false, comment: "作業"
    t.date "work_date", null: false, comment: "作業日"
    t.integer "machine_id", null: false, comment: "機械"
    t.string "machine_cd", limit: 16, null: false, comment: "機械番号"
    t.string "wk_type", limit: 2, null: false, comment: "作業カテゴリ"
    t.integer "wk_index", limit: 1, null: false, comment: "順序"
    t.integer "work_time", comment: "稼働時間"
    t.string "m_type", limit: 2, null: false, comment: "機械種別"
    t.integer "lock_flg", limit: 1, comment: "ロック"
    t.integer "lock_version", default: 1, comment: "ロックバージョン"
    t.datetime "created_at", null: false, comment: "作成日時"
    t.string "created_uid", limit: 16, null: false, comment: "新規登録者ID"
    t.datetime "updated_at", null: false, comment: "最終更新日時"
    t.string "updated_uid", limit: 16, null: false, comment: "更新者ID"
    t.datetime "deleted_at", comment: "削除日時"
    t.string "deleted_uid", limit: 16, comment: "削除者ID"
    t.integer "work_index", limit: 1, comment: "使用順序"
    t.index ["cargo_id"], name: "cargo_machines_1"
    t.index ["machine_cd"], name: "cargo_machines_4"
    t.index ["machine_id"], name: "cargo_machines_3"
    t.index ["work_date"], name: "cargo_machines_2"
  end

  create_table "cargo_masters", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "move_no", limit: 16, comment: "動静番号"
    t.string "work_name", limit: 128, comment: "作業名"
    t.string "work_place", limit: 32, comment: "場所"
    t.string "aggregate_category", limit: 1, comment: "事業区分"
    t.string "cargo_class", limit: 2, comment: "集計貨物分類"
    t.integer "lock_version", default: 1, comment: "ロックバージョン"
    t.datetime "created_at", null: false, comment: "作成日時"
    t.string "created_uid", limit: 16, null: false, comment: "新規登録者ID"
    t.datetime "updated_at", null: false, comment: "最終更新日時"
    t.string "updated_uid", limit: 16, null: false, comment: "更新者ID"
    t.datetime "deleted_at", comment: "削除日時"
    t.string "deleted_uid", limit: 16, comment: "削除者ID"
    t.index ["move_no"], name: "cargo_masters_1", unique: true
  end

  create_table "cargo_msgs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.date "work_date", null: false, comment: "作業日"
    t.string "login_id", limit: 16, null: false, comment: "従業員No"
    t.integer "user_id", null: false, comment: "作業者"
    t.string "msg", limit: 1024, comment: "メッセージ"
    t.string "created_uname", limit: 128, comment: "投稿者名"
    t.integer "lock_version", default: 1, comment: "ロックバージョン"
    t.datetime "created_at", null: false, comment: "作成日時"
    t.string "created_uid", limit: 16, null: false, comment: "新規登録者ID"
    t.datetime "updated_at", null: false, comment: "最終更新日時"
    t.string "updated_uid", limit: 16, null: false, comment: "更新者ID"
    t.datetime "deleted_at", comment: "削除日時"
    t.string "deleted_uid", limit: 16, comment: "削除者ID"
    t.index ["work_date", "login_id"], name: "cargo_msgs_1", unique: true
    t.index ["work_date", "user_id"], name: "cargo_msgs_2"
  end

  create_table "cargo_requests", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.date "work_date", null: false, comment: "作業日"
    t.string "department_cd", limit: 2, comment: "部署コード"
    t.string "department_nm", limit: 32, comment: "部署名"
    t.integer "work_class", limit: 1, comment: "作業区分"
    t.string "move_no", limit: 16, comment: "動静番号"
    t.string "move_no2", limit: 16, comment: "沿岸作業コード"
    t.integer "serial_no", limit: 1, comment: "連番"
    t.integer "work_no", limit: 2, comment: "作業NO"
    t.string "work_name", limit: 32, comment: "本船名・作業名"
    t.string "work_cd", limit: 4, comment: "貨物コード"
    t.string "cargo_name", limit: 32, comment: "貨物名"
    t.integer "io_flg", limit: 1, comment: "揚積"
    t.string "quantity", limit: 16, comment: "数量"
    t.string "work_place", limit: 16, comment: "場所"
    t.time "i_time", comment: "出勤時刻"
    t.time "s_time", comment: "開始時刻"
    t.time "e_time", comment: "終了予定時刻"
    t.integer "dirt_flg", limit: 1, comment: "汚れ作業"
    t.string "machine_nm", limit: 32, comment: "荷役機械"
    t.integer "fm_m", limit: 2, comment: "FM人数"
    t.integer "dm_m", limit: 2, comment: "DM人数"
    t.integer "wm_m", limit: 2, comment: "WM人数"
    t.integer "cr_m", limit: 2, comment: "クレーン人数"
    t.integer "ld_m", limit: 2, comment: "ローダ(主)人数"
    t.integer "ld_s", limit: 2, comment: "ローダ(副)人数"
    t.integer "bh_m", limit: 2, comment: "バックホー(主)人数"
    t.integer "bh_s", limit: 2, comment: "バックホー(副)人数"
    t.integer "sl_m", limit: 2, comment: "船内ローダ(主)人数"
    t.integer "sl_s", limit: 2, comment: "船内ローダ(副)人数"
    t.integer "bl_m", limit: 2, comment: "ブル(主)人数"
    t.integer "bl_s", limit: 2, comment: "ブル(副)人数"
    t.integer "lf_m", limit: 2, comment: "リフト(主)人数"
    t.integer "lf_s", limit: 2, comment: "リフト(副)人数"
    t.integer "sc_m", limit: 2, comment: "SC(主)人数"
    t.integer "sc_s", limit: 2, comment: "SC(副)人数"
    t.integer "tl_m", limit: 2, comment: "TL(主)人数"
    t.integer "tl_s", limit: 2, comment: "TL(副)人数"
    t.integer "ot_m", limit: 2, comment: "その他取扱者人数"
    t.integer "hd_w", limit: 2, comment: "ハンドル作業人数"
    t.integer "db_w", limit: 2, comment: "土場清掃作業人数"
    t.integer "hs_w", limit: 2, comment: "配車山均作業人数"
    t.integer "sn_w", limit: 2, comment: "船内作業員作業人数"
    t.integer "eg_w", limit: 2, comment: "沿岸作業員作業人数"
    t.integer "ot_w", limit: 2, comment: "他作業人数"
    t.integer "wk_w", limit: 2, comment: "作業員数計"
    t.string "note", limit: 128, comment: "備考"
    t.string "matter1", comment: "申送り事項1"
    t.string "matter2", comment: "申送り事項2"
    t.integer "esta_flg", limit: 1, comment: "荷役成立"
    t.integer "lock_version", default: 1, comment: "ロックバージョン"
    t.datetime "created_at", null: false, comment: "作成日時"
    t.string "created_uid", limit: 16, null: false, comment: "新規登録者ID"
    t.datetime "updated_at", null: false, comment: "最終更新日時"
    t.string "updated_uid", limit: 16, null: false, comment: "更新者ID"
    t.datetime "deleted_at", comment: "削除日時"
    t.string "deleted_uid", limit: 16, comment: "削除者ID"
    t.index ["work_date", "work_class", "move_no", "move_no2", "serial_no"], name: "cargo_requests_2", unique: true
    t.index ["work_date"], name: "cargo_requests_1"
  end

  create_table "cargo_workers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "cargo_id", null: false, comment: "作業"
    t.date "work_date", null: false, comment: "作業日"
    t.integer "user_id", null: false, comment: "作業者"
    t.string "login_id", limit: 16, null: false, comment: "従業員No"
    t.string "wk_type", limit: 2, null: false, comment: "作業カテゴリ"
    t.integer "wk_index", limit: 1, null: false, comment: "順序"
    t.string "wk_class", limit: 8, comment: "担当作業"
    t.integer "competence", limit: 1, comment: "力量"
    t.integer "work_time", comment: "作業時間"
    t.integer "orver_time", comment: "残業時間"
    t.integer "lock_flg", limit: 1, comment: "ロック"
    t.integer "lock_version", default: 1, comment: "ロックバージョン"
    t.datetime "created_at", null: false, comment: "作成日時"
    t.string "created_uid", limit: 16, null: false, comment: "新規登録者ID"
    t.datetime "updated_at", null: false, comment: "最終更新日時"
    t.string "updated_uid", limit: 16, null: false, comment: "更新者ID"
    t.datetime "deleted_at", comment: "削除日時"
    t.string "deleted_uid", limit: 16, comment: "削除者ID"
    t.integer "work_class", limit: 1, comment: "作業区分"
    t.time "s_time", comment: "開始時刻"
    t.time "e_time", comment: "終了予定時刻"
    t.integer "work_index", limit: 1, comment: "作業順序"
    t.integer "bus_flg", limit: 1, comment: "バスフラグ"
    t.integer "base_no", default: 1, comment: "登録時休暇申請状況"
    t.index ["cargo_id"], name: "cargo_workers_1"
    t.index ["login_id"], name: "cargo_workers_4"
    t.index ["user_id"], name: "cargo_workers_3"
    t.index ["work_date"], name: "cargo_workers_2"
  end

  create_table "cargos", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "cargo_request_id", null: false, comment: "本船作業依頼ID"
    t.date "work_date", null: false, comment: "作業日"
    t.integer "work_class", limit: 1, comment: "作業区分"
    t.string "move_no", limit: 16, comment: "動静番号"
    t.integer "serial_no", limit: 1, comment: "連番"
    t.integer "work_no", limit: 2, comment: "作業番号"
    t.integer "desp_index", comment: "表示順"
    t.string "work_name", limit: 32, comment: "作業名"
    t.string "work_cd", limit: 4, comment: "貨物コード"
    t.string "cargo_name", limit: 32, comment: "貨物名"
    t.integer "io_flg", limit: 1, comment: "揚積"
    t.string "quantity", limit: 16, comment: "数量"
    t.string "work_place", limit: 16, comment: "場所"
    t.time "i_time", comment: "出勤時刻"
    t.time "s_time", comment: "開始時刻"
    t.time "e_time", comment: "終了予定時刻"
    t.integer "dirt_flg", limit: 1, comment: "汚れ作業"
    t.string "machine_nm", limit: 32, comment: "荷役機械"
    t.integer "fm_m", limit: 2, comment: "FM必要人数"
    t.integer "dm_m", limit: 2, comment: "DM必要人数"
    t.integer "wm_m", limit: 2, comment: "WM必要人数"
    t.integer "cr_m", limit: 2, comment: "クレーン必要人数"
    t.integer "ld_m", limit: 2, comment: "ローダ(主)必要人数"
    t.integer "ld_s", limit: 2, comment: "ローダ(副)必要人数"
    t.integer "bh_m", limit: 2, comment: "バックホー(主)必要人数"
    t.integer "bh_s", limit: 2, comment: "バックホー(副)必要人数"
    t.integer "sl_m", limit: 2, comment: "船内ローダ(主)必要人数"
    t.integer "sl_s", limit: 2, comment: "船内ローダ(副)必要人数"
    t.integer "bl_m", limit: 2, comment: "ブル(主)必要人数"
    t.integer "bl_s", limit: 2, comment: "ブル(副)必要人数"
    t.integer "lf_m", limit: 2, comment: "リフト(主)必要人数"
    t.integer "lf_s", limit: 2, comment: "リフト(副)必要人数"
    t.integer "sc_m", limit: 2, comment: "SC(主)必要人数"
    t.integer "sc_s", limit: 2, comment: "SC(副)必要人数"
    t.integer "tl_m", limit: 2, comment: "TL(主)必要人数"
    t.integer "tl_s", limit: 2, comment: "TL(副)必要人数"
    t.integer "ot_m", limit: 2, comment: "その他取扱者人数"
    t.integer "wk_w", limit: 2, comment: "作業必要人数"
    t.string "note", limit: 128, comment: "備考"
    t.string "matter1", comment: "申送り事項1"
    t.string "matter2", comment: "申送り事項2"
    t.string "momo_fm", comment: "配番メモ（FM"
    t.string "momo_dm", comment: "配番メモ（DM"
    t.string "momo_mc", comment: "配番メモ（機械"
    t.string "momo_wi", comment: "配番メモ（ｳｨﾝﾁ取扱者"
    t.string "momo_dr", comment: "配番メモ（取扱者"
    t.string "momo_wk", comment: "配番メモ（船内／沿岸"
    t.integer "ob_np", limit: 1, comment: "OB人数"
    t.integer "hh_np", limit: 1, comment: "日立埠頭人数"
    t.integer "rk_np", limit: 2, comment: "労協人数"
    t.integer "wk_np", limit: 1, comment: "従事者人数"
    t.integer "work_time", comment: "作業時間"
    t.integer "orver_time", comment: "残業時間"
    t.integer "esta_flg", limit: 1, comment: "荷役成立"
    t.integer "conf_flg", limit: 1, comment: "配番完了フラグ"
    t.integer "lock_version", default: 1, comment: "ロックバージョン"
    t.datetime "created_at", null: false, comment: "作成日時"
    t.string "created_uid", limit: 16, null: false, comment: "新規登録者ID"
    t.datetime "updated_at", null: false, comment: "最終更新日時"
    t.string "updated_uid", limit: 16, null: false, comment: "更新者ID"
    t.datetime "deleted_at", comment: "削除日時"
    t.string "deleted_uid", limit: 16, comment: "削除者ID"
    t.integer "hd_w", limit: 2, comment: "ハンドル作業必要人数"
    t.integer "db_w", limit: 2, comment: "土場清掃作業必要人数"
    t.integer "hs_w", limit: 2, comment: "配車山均作業必要人数"
    t.integer "sn_w", limit: 2, comment: "船内作業員作業必要人数"
    t.integer "eg_w", limit: 2, comment: "沿岸作業員作業必要人数"
    t.integer "ot_w", limit: 2, comment: "他作業人数"
    t.integer "lock_flg", limit: 1, comment: "ロック(配番確定（実績登録）開始）"
    t.string "on_edit_uid", limit: 16, comment: "利用者ID"
    t.datetime "on_edit_at", comment: "利用開始日時"
    t.index ["work_date"], name: "cargos_1"
  end

  create_table "delayed_job_msgs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "delayed_job_id", default: 0, comment: "JobId"
    t.text "msg", comment: "メッセージ"
    t.text "queue", comment: "キュー"
    t.datetime "created_at", comment: "作成日時"
    t.datetime "updated_at", comment: "最終更新日時"
    t.text "payload", comment: "ペイロード"
    t.index ["delayed_job_id"], name: "delayed_job_msgs_1"
  end

  create_table "delayed_jobs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "priority", default: 0, comment: "優先度"
    t.integer "attempts", default: 0, comment: "実行回数"
    t.text "handler", comment: "ハンドル"
    t.text "last_error", comment: "最終エラー"
    t.datetime "run_at", comment: "実行日時"
    t.datetime "locked_at", comment: "ロック日時"
    t.datetime "failed_at", comment: "エラー日時"
    t.string "locked_by", comment: "ロック"
    t.text "queue", comment: "キュー"
    t.datetime "created_at", comment: "作成日時"
    t.datetime "updated_at", comment: "最終更新日時"
    t.index ["priority", "run_at"], name: "delayed_jobs_1"
  end

  create_table "lunch_locations", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "s_name", limit: 32, null: false, comment: "略称"
    t.string "name", limit: 64, null: false, comment: "名称"
    t.string "note", comment: "注意条項"
    t.integer "desp_index", null: false, comment: "表示順"
    t.text "cargo_key_wd", comment: "配番連携キーワード"
    t.integer "lock_version", default: 1, comment: "ロックバージョン"
    t.datetime "created_at", null: false, comment: "作成日時"
    t.string "created_uid", limit: 16, null: false, comment: "新規登録者ID"
    t.datetime "updated_at", null: false, comment: "最終更新日時"
    t.string "updated_uid", limit: 16, null: false, comment: "更新者ID"
    t.datetime "deleted_at", comment: "削除日時"
    t.string "deleted_uid", limit: 16, comment: "削除者ID"
  end

  create_table "lunch_menus", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "lunch_vendor_id", null: false, comment: "昼食注文先"
    t.string "name", limit: 32, null: false, comment: "名称"
    t.integer "desp_index", comment: "表示順"
    t.integer "lock_version", default: 1, comment: "ロックバージョン"
    t.datetime "created_at", null: false, comment: "作成日時"
    t.string "created_uid", limit: 16, null: false, comment: "新規登録者ID"
    t.datetime "updated_at", null: false, comment: "最終更新日時"
    t.string "updated_uid", limit: 16, null: false, comment: "更新者ID"
    t.datetime "deleted_at", comment: "削除日時"
    t.string "deleted_uid", limit: 16, comment: "削除者ID"
    t.string "s_name", limit: 5, null: false
  end

  create_table "lunch_order_locks", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.date "order_date", null: false, comment: "注文日"
    t.string "branche_cd", limit: 8, comment: "注文者グループCD"
    t.integer "lock_flg", limit: 1, comment: "ロックフラグ"
    t.integer "lock_version", default: 1, comment: "ロックバージョン"
    t.datetime "created_at", null: false, comment: "作成日時"
    t.string "created_uid", limit: 16, null: false, comment: "新規登録者ID"
    t.datetime "updated_at", null: false, comment: "最終更新日時"
    t.string "updated_uid", limit: 16, null: false, comment: "更新者ID"
    t.datetime "deleted_at", comment: "削除日時"
    t.string "deleted_uid", limit: 16, comment: "削除者ID"
    t.index ["branche_cd"], name: "lunch_order_locks_2"
    t.index ["order_date"], name: "lunch_order_locks_1"
  end

  create_table "lunch_orders", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.date "order_date", null: false, comment: "注文日"
    t.integer "user_id", null: false, comment: "注文者ID"
    t.string "branche_cd", limit: 8, comment: "注文者グループCD"
    t.integer "lunch_location_id", null: false, comment: "昼食配送先"
    t.integer "lunch_vendor_id", null: false, comment: "昼食注文先"
    t.integer "lunch_menu_id", null: false, comment: "昼食メニュー"
    t.integer "order_num", limit: 1, default: 1, null: false, comment: "注文数"
    t.integer "lock_version", default: 1, comment: "ロックバージョン"
    t.datetime "created_at", null: false, comment: "作成日時"
    t.string "created_uid", limit: 16, null: false, comment: "新規登録者ID"
    t.datetime "updated_at", null: false, comment: "最終更新日時"
    t.string "updated_uid", limit: 16, null: false, comment: "更新者ID"
    t.datetime "deleted_at", comment: "削除日時"
    t.string "deleted_uid", limit: 16, comment: "削除者ID"
    t.index ["order_date"], name: "lunch_orders_1"
    t.index ["user_id"], name: "lunch_orders_2"
  end

  create_table "lunch_vendors", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", limit: 32, null: false, comment: "名称"
    t.integer "wh_flg", limit: 1, default: 0, comment: "利用種別"
    t.integer "desp_index", comment: "表示順"
    t.integer "lock_version", default: 1, comment: "ロックバージョン"
    t.datetime "created_at", null: false, comment: "作成日時"
    t.string "created_uid", limit: 16, null: false, comment: "新規登録者ID"
    t.datetime "updated_at", null: false, comment: "最終更新日時"
    t.string "updated_uid", limit: 16, null: false, comment: "更新者ID"
    t.datetime "deleted_at", comment: "削除日時"
    t.string "deleted_uid", limit: 16, comment: "削除者ID"
    t.string "s_name", limit: 3, comment: "集計パネル表示"
  end

  create_table "machine_maintenances", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "machine_id", null: false, comment: "機械_id"
    t.date "s_date", null: false, comment: "メンテナンス開始日"
    t.date "e_date", comment: "メンテナンス終了日"
    t.string "note", comment: "メンテナンス内容"
    t.integer "lock_version", default: 1, comment: "ロックバージョン"
    t.datetime "created_at", null: false, comment: "作成日時"
    t.string "created_uid", limit: 16, null: false, comment: "新規登録者ID"
    t.datetime "updated_at", null: false, comment: "最終更新日時"
    t.string "updated_uid", limit: 16, null: false, comment: "更新者ID"
    t.datetime "deleted_at", comment: "削除日時"
    t.string "deleted_uid", limit: 16, comment: "削除者ID"
    t.integer "maintenanc_type", limit: 1, comment: "分類"
    t.integer "expense", comment: "費用"
    t.string "representative", limit: 64, comment: "対応者(責任者"
    t.index ["e_date"], name: "machine_maintenances_3"
    t.index ["machine_id"], name: "machine_maintenances_1"
    t.index ["s_date"], name: "machine_maintenances_2"
  end

  create_table "machines", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "cd", limit: 16, null: false, comment: "機械番号"
    t.string "name", limit: 16, null: false, comment: "機械名"
    t.string "m_type", limit: 2, null: false, comment: "機械種別"
    t.string "branch_cd", limit: 8, comment: "所属CD"
    t.string "color", limit: 8, comment: "パネル色"
    t.string "a_category", limit: 1, comment: "実績集計区分"
    t.integer "light_oil", limit: 1, comment: "免税軽油該当"
    t.integer "maintenance", limit: 1, comment: "メンテナンス対象"
    t.integer "u_maintenance", limit: 1, comment: "メンテナンス中"
    t.integer "lock_version", default: 1, comment: "ロックバージョン"
    t.datetime "created_at", null: false, comment: "作成日時"
    t.string "created_uid", limit: 16, null: false, comment: "新規登録者ID"
    t.datetime "updated_at", null: false, comment: "最終更新日時"
    t.string "updated_uid", limit: 16, null: false, comment: "更新者ID"
    t.datetime "deleted_at", comment: "削除日時"
    t.string "deleted_uid", limit: 16, comment: "削除者ID"
    t.date "start_day", comment: "稼働(導入)開始日"
    t.date "last_mainte_day", comment: "最終メンテナンス日"
    t.string "maker", limit: 64, comment: "メーカー"
    t.string "wk_place1", limit: 16, comment: "配番場所１"
    t.string "wk_place2", limit: 16, comment: "配番場所2"
    t.string "wk_place3", limit: 16, comment: "配番場所3"
    t.integer "cargo_class09", limit: 1, comment: "配番貨物_肥料"
    t.integer "cargo_class23_3818", limit: 1, comment: "配番貨物_PKS"
    t.integer "cargo_class23_3816", limit: 1, comment: "配番貨物_ﾍﾟﾚｯﾄ"
    t.integer "cargo_class12", limit: 1, comment: "配番貨物_工業塩"
    t.integer "cargo_class01", limit: 1, comment: "配番貨物_石炭"
    t.integer "cargo_class06", limit: 1, comment: "配番貨物_亜鉛鉱"
    t.integer "cargo_class05", limit: 1, comment: "配番貨物_ｺｰｸｽ"
    t.integer "cargo_class07", limit: 1, comment: "配番貨物_銅精鉱"
    t.integer "cargo_class98", limit: 1, comment: "配番貨物_コンテナ"
    t.integer "cargo_class17", limit: 1, comment: "配番貨物_スクラップ"
    t.index ["m_type"], name: "machines_1"
  end

  create_table "result_cargo_machines", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "result_cargo_id", null: false, comment: "作業"
    t.integer "cargo_machine_id", comment: "作業従事機械"
    t.date "work_date", null: false, comment: "作業日"
    t.integer "machine_id", null: false, comment: "機械"
    t.string "machine_cd", limit: 16, null: false, comment: "機械番号"
    t.string "wk_type", limit: 2, null: false, comment: "作業カテゴリ"
    t.integer "wk_index", limit: 1, null: false, comment: "順序"
    t.integer "work_time", comment: "稼働時間"
    t.string "m_type", limit: 2, null: false, comment: "機械種別"
    t.integer "maintenanc_type", limit: 1, comment: "故障発生"
    t.date "e_date", comment: "復旧見込日"
    t.string "note", comment: "内容"
    t.integer "lock_version", default: 1, comment: "ロックバージョン"
    t.datetime "created_at", null: false, comment: "作成日時"
    t.string "created_uid", limit: 16, null: false, comment: "新規登録者ID"
    t.datetime "updated_at", null: false, comment: "最終更新日時"
    t.string "updated_uid", limit: 16, null: false, comment: "更新者ID"
    t.datetime "deleted_at", comment: "削除日時"
    t.string "deleted_uid", limit: 16, comment: "削除者ID"
    t.integer "work_index", limit: 1, comment: "使用順序"
    t.index ["result_cargo_id"], name: "result_cargo_machines_1"
  end

  create_table "result_cargo_workers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "result_cargo_id", null: false, comment: "作業"
    t.integer "cargo_worker_id", comment: "作業従事"
    t.date "work_date", null: false, comment: "作業日"
    t.integer "user_id", null: false, comment: "作業者"
    t.string "login_id", limit: 16, null: false, comment: "従業員No"
    t.string "wk_type", limit: 2, null: false, comment: "作業カテゴリ"
    t.integer "wk_index", limit: 1, null: false, comment: "順序"
    t.string "wk_class", limit: 8, comment: "担当作業"
    t.time "s_time", comment: "開始時刻"
    t.time "e_time", comment: "終了予定時刻"
    t.integer "work_time", comment: "作業時間"
    t.integer "orver_time", comment: "残業時間"
    t.integer "work_class", limit: 1, comment: "作業区分"
    t.integer "base_no", default: 1, comment: "出欠"
    t.integer "lock_version", default: 1, comment: "ロックバージョン"
    t.datetime "created_at", null: false, comment: "作成日時"
    t.string "created_uid", limit: 16, null: false, comment: "新規登録者ID"
    t.datetime "updated_at", null: false, comment: "最終更新日時"
    t.string "updated_uid", limit: 16, null: false, comment: "更新者ID"
    t.datetime "deleted_at", comment: "削除日時"
    t.string "deleted_uid", limit: 16, comment: "削除者ID"
    t.integer "work_index", limit: 1, comment: "作業順序"
    t.integer "bus_flg", limit: 1, comment: "バスフラグ"
    t.index ["login_id"], name: "result_cargo_workers_4"
    t.index ["result_cargo_id"], name: "result_cargo_workers_1"
    t.index ["user_id"], name: "result_cargo_workers_3"
    t.index ["work_date"], name: "result_cargo_workers_2"
  end

  create_table "result_cargos", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "cargo_request_id", null: false, comment: "本船作業依頼ID"
    t.integer "cargo_id", null: false, comment: "荷役予定ID"
    t.date "work_date", null: false, comment: "作業日"
    t.integer "work_class", limit: 1, comment: "作業区分"
    t.string "move_no", limit: 16, comment: "動静番号"
    t.integer "serial_no", limit: 1, comment: "連番"
    t.integer "work_no", limit: 2, comment: "作業番号"
    t.integer "desp_index", comment: "表示順"
    t.string "work_name", limit: 32, comment: "作業名"
    t.string "work_cd", limit: 4, comment: "貨物コード"
    t.string "cargo_name", limit: 32, comment: "貨物名"
    t.integer "io_flg", limit: 1, comment: "揚積"
    t.string "quantity", limit: 16, comment: "数量"
    t.string "work_place", limit: 16, comment: "場所"
    t.time "i_time", comment: "出勤時刻"
    t.time "s_time", comment: "開始時刻"
    t.time "e_time", comment: "終了予定時刻"
    t.integer "dirt_flg", limit: 1, comment: "汚れ作業"
    t.string "machine_nm", limit: 32, comment: "荷役機械"
    t.integer "fm_m", limit: 2, comment: "FM必要人数"
    t.integer "dm_m", limit: 2, comment: "DM必要人数"
    t.integer "wm_m", limit: 2, comment: "WM必要人数"
    t.integer "cr_m", limit: 2, comment: "クレーン必要人数"
    t.integer "ld_m", limit: 2, comment: "ローダ(主)必要人数"
    t.integer "ld_s", limit: 2, comment: "ローダ(副)必要人数"
    t.integer "bh_m", limit: 2, comment: "バックホー(主)必要人数"
    t.integer "bh_s", limit: 2, comment: "バックホー(副)必要人数"
    t.integer "sl_m", limit: 2, comment: "船内ローダ(主)必要人数"
    t.integer "sl_s", limit: 2, comment: "船内ローダ(副)必要人数"
    t.integer "bl_m", limit: 2, comment: "ブル(主)必要人数"
    t.integer "bl_s", limit: 2, comment: "ブル(副)必要人数"
    t.integer "lf_m", limit: 2, comment: "リフト(主)必要人数"
    t.integer "lf_s", limit: 2, comment: "リフト(副)必要人数"
    t.integer "sc_m", limit: 2, comment: "SC(主)必要人数"
    t.integer "sc_s", limit: 2, comment: "SC(副)必要人数"
    t.integer "tl_m", limit: 2, comment: "TL(主)必要人数"
    t.integer "tl_s", limit: 2, comment: "TL(副)必要人数"
    t.integer "ot_m", limit: 2, comment: "その他取扱者必要人数"
    t.integer "hd_w", limit: 2, comment: "ハンドル作業必要人数"
    t.integer "db_w", limit: 2, comment: "土場清掃作業必要人数"
    t.integer "hs_w", limit: 2, comment: "配車山均作業必要人数"
    t.integer "sn_w", limit: 2, comment: "船内作業員作業必要人数"
    t.integer "eg_w", limit: 2, comment: "沿岸作業員作業必要人数"
    t.integer "ot_w", limit: 2, comment: "他作業人数"
    t.integer "wk_w", limit: 2, comment: "作業必要人数"
    t.string "note", limit: 128, comment: "備考"
    t.string "matter1", comment: "申送り事項1"
    t.string "matter2", comment: "申送り事項2"
    t.string "momo_fm", comment: "配番メモ（FM"
    t.string "momo_dm", comment: "配番メモ（DM"
    t.string "momo_mc", comment: "配番メモ（機械"
    t.string "momo_wi", comment: "配番メモ（ｳｨﾝﾁ取扱者"
    t.string "momo_dr", comment: "配番メモ（取扱者"
    t.string "momo_wk", comment: "配番メモ（船内／沿岸"
    t.integer "ob_np", limit: 1, comment: "OB人数"
    t.integer "hh_np", limit: 1, comment: "日立埠頭人数"
    t.integer "rk_np", limit: 2, comment: "労協人数"
    t.integer "wk_np", limit: 1, comment: "従事者人数"
    t.integer "work_time", comment: "作業時間"
    t.integer "orver_time", comment: "残業時間"
    t.integer "esta_flg", limit: 1, comment: "荷役成立"
    t.integer "conf_flg", limit: 1, comment: "配番完了フラグ"
    t.integer "lock_version", default: 1, comment: "ロックバージョン"
    t.datetime "created_at", null: false, comment: "作成日時"
    t.string "created_uid", limit: 16, null: false, comment: "新規登録者ID"
    t.datetime "updated_at", null: false, comment: "最終更新日時"
    t.string "updated_uid", limit: 16, null: false, comment: "更新者ID"
    t.datetime "deleted_at", comment: "削除日時"
    t.string "deleted_uid", limit: 16, comment: "削除者ID"
    t.string "on_edit_uid", limit: 16, comment: "利用者ID"
    t.datetime "on_edit_at", comment: "利用開始日時"
    t.index ["work_date"], name: "result_cargos_1"
  end

  create_table "user_auths", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "login_id", limit: 16, null: false, comment: "従業員No"
    t.integer "view_boards", limit: 1, default: 0, comment: "掲示表示"
    t.integer "lunch_orders", limit: 1, default: 0, comment: "昼食集計"
    t.integer "boards", limit: 1, default: 0, comment: "掲示管理"
    t.integer "vacations", limit: 1, default: 0, comment: "休暇管理"
    t.integer "result_assignment", limit: 1, default: 0, comment: "配番実績"
    t.integer "cargo_requests", limit: 1, default: 0, comment: "作業依頼"
    t.integer "cargos", limit: 1, default: 0, comment: "荷役予定"
    t.integer "wk_assignment", limit: 1, default: 0, comment: "配番"
    t.integer "sagyo_request", limit: 1, default: 0, comment: "作業依頼書"
    t.integer "cargo_request_head_count", limit: 1, default: 0, comment: "必要人数表"
    t.integer "cargo_head_count", limit: 1, default: 0, comment: "配番人数表"
    t.integer "cargo_worker_schedule", limit: 1, default: 0, comment: "荷役作業員予定表"
    t.integer "cargo_schedule", limit: 1, default: 0, comment: "配番表（予定"
    t.integer "time_sheet", limit: 1, default: 0, comment: "出勤時間表"
    t.integer "work_daily_sheet", limit: 1, default: 0, comment: "出欠日報・残業届"
    t.integer "time_card", limit: 1, default: 0, comment: "タイムカードデータ"
    t.integer "cargo_result", limit: 1, default: 0, comment: "配番表(実績)"
    t.integer "sagyo_haiban", limit: 1, default: 0, comment: "荷役実績"
    t.integer "daily_cargo_work_result", limit: 1, default: 0, comment: "日別荷役作業実績出力"
    t.integer "monthly_cargo_work_result", limit: 1, default: 0, comment: "荷役作業実績表出力"
    t.integer "tax_free_machines_pdf", limit: 1, default: 0, comment: "免税軽油稼働実績表出力"
    t.integer "cargo_worker_result", limit: 1, default: 0, comment: "荷役作業員実績表出力"
    t.integer "lunch_summary", limit: 1, default: 0, comment: "昼食集計帳票出力"
    t.integer "work_time_summary", limit: 1, default: 0, comment: "現業職労働時間・時間外管理表出力"
    t.integer "cargo_work_detail", limit: 1, default: 0, comment: "荷役作業明細一覧出力"
    t.integer "worker_work_summary", limit: 1, default: 0, comment: "作業員毎作業一覧出力"
    t.integer "lock_version", default: 1, comment: "ロックバージョン"
    t.datetime "created_at", null: false, comment: "作成日時"
    t.string "created_uid", limit: 16, null: false, comment: "新規登録者ID"
    t.datetime "updated_at", null: false, comment: "最終更新日時"
    t.string "updated_uid", limit: 16, null: false, comment: "更新者ID"
    t.datetime "deleted_at", comment: "削除日時"
    t.string "deleted_uid", limit: 16, comment: "削除者ID"
    t.integer "p_orver_time_sheet", limit: 1, default: 0, comment: "勤怠時間外管理表利用可否"
    t.integer "work_time_csv_import", limit: 1, default: 0, comment: "勤務時間取込利用可否"
    t.index ["login_id"], name: "user_auths_1", unique: true
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "login_id", limit: 16, null: false, comment: "従業員No"
    t.string "name", limit: 64, null: false, comment: "従業員氏名"
    t.string "password", limit: 32, null: false, comment: "パスワード"
    t.integer "bbs_max_count", limit: 1, comment: "新着掲示件数"
    t.integer "bbs_mail_flg", limit: 1, comment: "掲示メール受信設定"
    t.integer "holiday_mail_flg", limit: 1, comment: "休暇申請リマインドメール受信設定"
    t.string "mail", comment: "メールアドレス"
    t.string "tel", comment: "電話番号"
    t.integer "auth_flg", limit: 1, comment: "権限フラグ"
    t.integer "lock_version", default: 1, comment: "ロックバージョン"
    t.datetime "created_at", null: false, comment: "作成日時"
    t.string "created_uid", limit: 16, null: false, comment: "新規登録者ID"
    t.datetime "updated_at", null: false, comment: "最終更新日時"
    t.string "updated_uid", limit: 16, null: false, comment: "更新者ID"
    t.datetime "deleted_at", comment: "削除日時"
    t.string "deleted_uid", limit: 16, comment: "削除者ID"
    t.string "remind_question", limit: 32
    t.string "remind_answer", limit: 32
    t.datetime "last_logined_at"
    t.string "branch_cd", limit: 8, comment: "（親方用）担当グループ"
    t.index ["login_id"], name: "users_1", unique: true
  end

  create_table "vacation_base6_locks", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "t_year", limit: 2, null: false, comment: "対象年"
    t.integer "t_month", limit: 1, null: false, comment: "対象月"
    t.string "branche_cd", limit: 8, comment: "対象グループCD"
    t.integer "lock_flg", limit: 1, comment: "ロックフラグ"
    t.integer "lock_version", default: 1, comment: "ロックバージョン"
    t.datetime "created_at", null: false, comment: "作成日時"
    t.string "created_uid", limit: 16, null: false, comment: "新規登録者ID"
    t.datetime "updated_at", null: false, comment: "最終更新日時"
    t.string "updated_uid", limit: 16, null: false, comment: "更新者ID"
    t.datetime "deleted_at", comment: "削除日時"
    t.string "deleted_uid", limit: 16, comment: "削除者ID"
    t.index ["t_year", "t_month", "branche_cd"], name: "vacation_base6_lock_1"
  end

  create_table "vacation_types", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "base_no", null: false, comment: "勤怠ID(既存システム連携用）"
    t.string "cd", null: false, comment: "勤怠コード"
    t.string "name", comment: "配番用表記"
    t.string "assign_name", comment: "配番表用表記"
    t.string "time_sheet_name", comment: "出勤時間表用表記"
    t.integer "lock_version", default: 1, comment: "ロックバージョン"
    t.datetime "created_at", null: false, comment: "作成日時"
    t.string "created_uid", limit: 16, null: false, comment: "新規登録者ID"
    t.datetime "updated_at", null: false, comment: "最終更新日時"
    t.string "updated_uid", limit: 16, null: false, comment: "更新者ID"
    t.datetime "deleted_at", comment: "削除日時"
    t.string "deleted_uid", limit: 16, comment: "削除者ID"
    t.integer "desp_index"
    t.index ["base_no"], name: "vacation_types_1", unique: true
  end

  create_table "vacations", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "user_id", null: false, comment: "申請者"
    t.string "login_id", limit: 16, null: false, comment: "申請者従業員No"
    t.string "branch_cd", limit: 8, comment: "所属CD"
    t.date "vacation_day", null: false, comment: "休暇日"
    t.integer "vacation_type_id", null: false, comment: "休暇種別"
    t.integer "base_no", null: false, comment: "休暇種別(勤怠ID)"
    t.integer "at_work", limit: 1, comment: "休日対応可否"
    t.datetime "app_at", comment: "申請日時"
    t.integer "sts", limit: 1, comment: "状態"
    t.integer "authorizer_id", comment: "承認者"
    t.string "authorizer_name", limit: 64, comment: "承認者名"
    t.datetime "approval_at", comment: "承認日"
    t.string "reason", limit: 1024, comment: "差戻理由"
    t.date "origin_date", comment: "振替元休暇日"
    t.integer "vacation_id", comment: "振替元休暇申請"
    t.string "leav_time", limit: 8, comment: "退勤希望時刻"
    t.integer "lock_version", default: 1, comment: "ロックバージョン"
    t.datetime "created_at", null: false, comment: "作成日時"
    t.string "created_uid", limit: 16, null: false, comment: "新規登録者ID"
    t.datetime "updated_at", null: false, comment: "最終更新日時"
    t.string "updated_uid", limit: 16, null: false, comment: "更新者ID"
    t.datetime "deleted_at", comment: "削除日時"
    t.string "deleted_uid", limit: 16, comment: "削除者ID"
    t.string "arriv_time", limit: 8, comment: "出勤希望時刻"
    t.index ["branch_cd"], name: "vacations_2"
    t.index ["sts", "base_no"], name: "vacations_3"
    t.index ["user_id", "vacation_day"], name: "vacations_1", unique: true
  end

  create_table "wh_calendars", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.date "t_date", null: false, comment: "日付"
    t.integer "wh_flg", limit: 1, default: 0, comment: "平日／公休日フラグ"
    t.integer "lunch_vendor_id", comment: "昼食注文先"
    t.integer "ph_max", limit: 1, comment: "平日公休出勤上限数"
    t.integer "lock_version", default: 1, comment: "ロックバージョン"
    t.datetime "created_at", null: false, comment: "作成日時"
    t.string "created_uid", limit: 16, null: false, comment: "新規登録者ID"
    t.datetime "updated_at", null: false, comment: "最終更新日時"
    t.string "updated_uid", limit: 16, null: false, comment: "更新者ID"
    t.datetime "deleted_at", comment: "削除日時"
    t.string "deleted_uid", limit: 16, comment: "削除者ID"
    t.string "hname", limit: 64
    t.index ["t_date"], name: "wh_calendars_1", unique: true
  end

  create_table "wh_summaries", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "t_year", limit: 2, null: false, comment: "対象年"
    t.integer "t_month", limit: 1, null: false, comment: "対象月"
    t.date "s_date", null: false, comment: "開始日"
    t.date "e_date", null: false, comment: "終了日"
    t.date "cs_date", comment: "カレンダー開始日"
    t.date "ce_date", comment: "カレンダー終了日"
    t.integer "sunday_num", limit: 1, comment: "日曜日数"
    t.integer "holiday_num", limit: 1, comment: "祝祭日数"
    t.integer "h_setting_min", limit: 1, comment: "公休日設定下限"
    t.integer "lock_version", default: 1, comment: "ロックバージョン"
    t.datetime "created_at", null: false, comment: "作成日時"
    t.string "created_uid", limit: 16, null: false, comment: "新規登録者ID"
    t.datetime "updated_at", null: false, comment: "最終更新日時"
    t.string "updated_uid", limit: 16, null: false, comment: "更新者ID"
    t.datetime "deleted_at", comment: "削除日時"
    t.string "deleted_uid", limit: 16, comment: "削除者ID"
    t.index ["t_year", "t_month"], name: "wh_summaries_1", unique: true
  end

  create_table "wokers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.date "applicable", null: false, comment: "改定日"
    t.string "login_id", limit: 16, null: false, comment: "従業員No"
    t.string "s_name", limit: 16, null: false, comment: "パネル表示名"
    t.string "branch_cd", limit: 8, comment: "グループCD"
    t.integer "competence_dm", limit: 1, comment: "DM"
    t.integer "competence_lf", limit: 1, comment: "リフト"
    t.integer "desp_index", comment: "表示順"
    t.integer "lock_version", default: 1, comment: "ロックバージョン"
    t.datetime "created_at", null: false, comment: "作成日時"
    t.string "created_uid", limit: 16, null: false, comment: "新規登録者ID"
    t.datetime "updated_at", null: false, comment: "最終更新日時"
    t.string "updated_uid", limit: 16, null: false, comment: "更新者ID"
    t.datetime "deleted_at", comment: "削除日時"
    t.string "deleted_uid", limit: 16, comment: "削除者ID"
    t.integer "competence_ca", limit: 1
    t.integer "competence_tl", limit: 1
    t.integer "competence_fmm", limit: 1
    t.integer "competence_fmc", limit: 1
    t.integer "competence_fma", limit: 1
    t.integer "competence_fmp", limit: 1
    t.integer "competence_sn", limit: 1
    t.integer "competence_od", limit: 1
    t.integer "competence_cc", limit: 1
    t.integer "competence_em", limit: 1
    t.integer "competence_ep", limit: 1
    t.integer "competence_cr3", limit: 1
    t.integer "competence_cr5", limit: 1
    t.integer "competence_cr6", limit: 1
    t.integer "competence_cr7", limit: 1
    t.integer "competence_cru", limit: 1
    t.integer "competence_wwm", limit: 1
    t.integer "competence_crg", limit: 1
    t.integer "competence_scm", limit: 1
    t.integer "competence_scc", limit: 1
    t.integer "competence_tlm", limit: 1
    t.integer "competence_tlc", limit: 1
    t.integer "competence_lfl", limit: 1
    t.integer "competence_ldc", limit: 1
    t.integer "competence_ldm", limit: 1
    t.integer "competence_bhh", limit: 1
    t.integer "competence_bhs", limit: 1
    t.integer "competence_bld", limit: 1
    t.integer "competence_blh", limit: 1
    t.integer "competence_slm", limit: 1
    t.integer "competence_slc", limit: 1
    t.integer "competence_sw", limit: 1
    t.integer "competence_sp", limit: 1
    t.integer "competence_clr", limit: 1
    t.integer "competence_crp", limit: 1
    t.integer "competence_cre", limit: 1
    t.integer "competence_crs", limit: 1
    t.integer "competence_w3", limit: 1
    t.integer "competence_s5", limit: 1
    t.integer "competence_s7", limit: 1
    t.integer "competence_wgd", limit: 1
    t.integer "competence_wal", limit: 1
    t.integer "competence_w6e", limit: 1
    t.integer "competence_wbg", limit: 1
    t.integer "competence_wsm", limit: 1
    t.integer "competence_wsc", limit: 1
    t.integer "competence_wc", limit: 1
    t.integer "competence_wcc", limit: 1
    t.integer "competence_wlg", limit: 1
    t.integer "competence_mt", limit: 1
    t.integer "w_type", limit: 1
    t.index ["applicable", "login_id"], name: "wokers_1", unique: true
  end

  create_table "work_time_aggregates", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "t_year", limit: 2, null: false, comment: "集計年"
    t.integer "t_month", limit: 1, null: false, comment: "集計月"
    t.string "aggr_flg", limit: 1, null: false, comment: "集計対象"
    t.integer "t_id", comment: "作業者ID(機械ID)"
    t.string "t_cd", limit: 16, comment: "従業員No(機械番号)"
    t.integer "work_time", default: 0, comment: "法定作業時間(月合計"
    t.integer "orver_time", default: 0, comment: "法定残業時間(月合計"
    t.integer "l_ot_wd", default: 0, comment: "法定要素（休日労働時間）"
    t.integer "l_ot_45", default: 0, comment: "法定(45)"
    t.integer "l_ot_80", default: 0, comment: "法定(80)"
    t.integer "p_work_time", default: 0, comment: "所定作業時間(月合計"
    t.integer "p_orver_time", default: 0, comment: "所定残業時間(月合計"
    t.integer "p_early_time", default: 0, comment: "所定早出時間(月合計"
    t.integer "wd_base6_num", limit: 1, default: 0, comment: "平日公休出勤数(月合計"
    t.integer "hd_base6_num", limit: 1, default: 0, comment: "日曜公休出勤数(月合計"
    t.integer "lock_version", default: 1, comment: "ロックバージョン"
    t.datetime "created_at", null: false, comment: "作成日時"
    t.string "created_uid", limit: 16, null: false, comment: "新規登録者ID"
    t.datetime "updated_at", null: false, comment: "最終更新日時"
    t.string "updated_uid", limit: 16, null: false, comment: "更新者ID"
    t.datetime "deleted_at", comment: "削除日時"
    t.string "deleted_uid", limit: 16, comment: "削除者ID"
    t.integer "l_ot_45d", default: 0, comment: "法定(45)日々"
    t.index ["t_id"], name: "work_time_aggregates_2"
    t.index ["t_year", "t_month", "aggr_flg", "t_cd"], name: "work_time_aggregates_1"
  end

  create_table "work_time_summaries", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.date "work_date", null: false, comment: "作業日"
    t.string "aggr_flg", limit: 1, null: false, comment: "集計対象"
    t.integer "t_id", comment: "作業者ID(機械ID)"
    t.string "t_cd", limit: 16, comment: "従業員No(機械番号)"
    t.time "s_time", comment: "開始時刻（出勤時刻"
    t.time "e_time", comment: "終了時刻"
    t.integer "bus_flg", limit: 1, comment: "バスフラグ"
    t.integer "work_class", limit: 1, comment: "作業区分"
    t.integer "base_no", default: 1, comment: "登録時休暇申請状況"
    t.integer "work_time", comment: "法定作業時間"
    t.integer "orver_time", comment: "法定残業時間"
    t.integer "p_work_time", comment: "所定作業時間"
    t.integer "p_orver_time", comment: "所定残業時間"
    t.integer "p_early_time", comment: "所定早出時間"
    t.integer "data_root", comment: "データ元"
    t.integer "lock_version", default: 1, comment: "ロックバージョン"
    t.datetime "created_at", null: false, comment: "作成日時"
    t.string "created_uid", limit: 16, null: false, comment: "新規登録者ID"
    t.datetime "updated_at", null: false, comment: "最終更新日時"
    t.string "updated_uid", limit: 16, null: false, comment: "更新者ID"
    t.datetime "deleted_at", comment: "削除日時"
    t.string "deleted_uid", limit: 16, comment: "削除者ID"
    t.index ["t_id"], name: "work_time_summaries_2"
    t.index ["work_date", "aggr_flg", "t_cd"], name: "work_time_summaries_1", unique: true
  end

end
