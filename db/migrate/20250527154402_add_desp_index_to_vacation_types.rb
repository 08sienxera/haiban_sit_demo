class AddDespIndexToVacationTypes < ActiveRecord::Migration[7.1]
  def change
    add_column :vacation_types ,:desp_index, :integer
  end
end
