class AddLockFlgToCargos < ActiveRecord::Migration[7.1]
  def change
    add_column :cargos ,:lock_flg, :integer, :limit =>1 ,:comment => "ロック(配番確定（実績登録）開始）"
  end
end
