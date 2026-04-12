class AddSnameToLunchVendor < ActiveRecord::Migration[7.1]
  def change
    add_column :lunch_vendors, :s_name, :string, :limit=>3, :comment =>"集計パネル表示"
  end
end
