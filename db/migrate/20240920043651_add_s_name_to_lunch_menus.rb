class AddSNameToLunchMenus < ActiveRecord::Migration[7.1]
  def change
    add_column :lunch_menus ,:s_name, :string, :limit =>5, :null =>false
  end
end
