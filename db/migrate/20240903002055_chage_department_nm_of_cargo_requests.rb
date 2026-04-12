class ChageDepartmentNmOfCargoRequests < ActiveRecord::Migration[7.1]
  def change
    change_column :cargo_requests ,:department_nm, :string, :limit =>32,:comment => "部署名"
  end
end
