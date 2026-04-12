class AddBranchCdTousers < ActiveRecord::Migration[7.1]
  def change
    add_column :users ,:branch_cd, :string, :limit =>8,:comment => "（親方用）担当グループ"
  end
end
