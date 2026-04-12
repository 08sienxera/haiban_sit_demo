class AddWorkTimeCsvImportToUseAuths < ActiveRecord::Migration[7.1]
  def change
    add_column :user_auths ,:work_time_csv_import, :integer, :limit =>1, :default=>0,:comment=>"勤務時間取込利用可否"
  end
end
