class AddPOrverTimeSheetToUseAuths < ActiveRecord::Migration[7.1]
  def change
    add_column :user_auths ,:p_orver_time_sheet, :integer, :limit =>1, :default=>0, :comment=>"勤怠時間外管理表利用可否"
  end
end
