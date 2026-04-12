class AddOnEditToCargosAndResultCargos < ActiveRecord::Migration[7.1]
  def change
    add_column :cargos ,:on_edit_uid, :string, :limit =>16 ,:comment => "利用者ID"
    add_column :cargos ,:on_edit_at, :datetime ,:comment => "利用開始日時"
    add_column :result_cargos ,:on_edit_uid, :string, :limit =>16 ,:comment => "利用者ID"
    add_column :result_cargos ,:on_edit_at, :datetime ,:comment => "利用開始日時"
  end
end
