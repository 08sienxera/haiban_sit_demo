class AddIndexBasenoToVacationTypes < ActiveRecord::Migration[7.1]
  def change
    # add_index :vacation_types, :base_no
    add_index :vacation_types, [:base_no], :name =>:vacation_types_1 ,:unique => true

  end

end
