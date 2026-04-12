class AddWtypeFieldToWokers < ActiveRecord::Migration[7.1]
  def change
    add_column :wokers ,:w_type, :integer, :limit =>1
  end
end
