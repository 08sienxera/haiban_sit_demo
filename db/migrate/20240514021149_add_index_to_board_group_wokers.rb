class AddIndexToBoardGroupWokers < ActiveRecord::Migration[7.1]
  def change
    add_index :board_group_wokers, [:board_group_id], :name =>:board_group_wokers_1

  end
end
