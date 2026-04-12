class AddFileNamesToBoards < ActiveRecord::Migration[7.1]
  def change
    add_column :boards ,:file_name2, :string,:comment => "添付ファイル２"
    add_column :boards ,:file_name3, :string,:comment => "添付ファイル３"
    add_column :boards ,:file_name4, :string,:comment => "添付ファイル４"
    add_column :boards ,:file_name5, :string,:comment => "添付ファイル５"
  end
end
