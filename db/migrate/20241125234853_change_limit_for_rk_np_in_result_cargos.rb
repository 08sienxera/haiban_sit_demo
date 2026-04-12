class ChangeLimitForRkNpInResultCargos < ActiveRecord::Migration[7.1]
  def up
    change_column :result_cargos, :rk_np, :integer, limit: 2
  end
  def down
    change_column :result_cargos, :rk_np, :integer, limit: 1
  end
end
