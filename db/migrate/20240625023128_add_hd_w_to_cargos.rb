class AddHdWToCargos < ActiveRecord::Migration[7.1]
  def change
    add_column :cargos ,:hd_w, :integer, :limit =>2 ,:comment => "ハンドル作業必要人数"
    add_column :cargos ,:db_w, :integer, :limit =>2 ,:comment => "土場清掃作業必要人数"
    add_column :cargos ,:hs_w, :integer, :limit =>2 ,:comment => "配車山均作業必要人数"
    add_column :cargos ,:sn_w, :integer, :limit =>2 ,:comment => "船内作業員作業必要人数"
    add_column :cargos ,:eg_w, :integer, :limit =>2 ,:comment => "沿岸作業員作業必要人数"
    add_column :cargos ,:ot_w, :integer, :limit =>2 ,:comment => "他作業人数"
  end
end
