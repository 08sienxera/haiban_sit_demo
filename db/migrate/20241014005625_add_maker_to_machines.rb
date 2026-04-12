class AddMakerToMachines < ActiveRecord::Migration[7.1]
  def change
    add_column :machines ,:maker, :string, :limit =>64,:comment => "メーカー"
    add_column :machines ,:wk_place1, :string, :limit =>16,:comment => "配番場所１"
    add_column :machines ,:wk_place2, :string, :limit =>16,:comment => "配番場所2"
    add_column :machines ,:wk_place3, :string, :limit =>16,:comment => "配番場所3"
    add_column :machines ,:cargo_class09, :integer, :limit =>1,:comment => "配番貨物_肥料"
    add_column :machines ,:cargo_class23_3818, :integer, :limit =>1,:comment => "配番貨物_PKS"
    add_column :machines ,:cargo_class23_3816, :integer, :limit =>1,:comment => "配番貨物_ﾍﾟﾚｯﾄ"
    add_column :machines ,:cargo_class12, :integer, :limit =>1,:comment => "配番貨物_工業塩"
    add_column :machines ,:cargo_class01, :integer, :limit =>1,:comment => "配番貨物_石炭"
    add_column :machines ,:cargo_class06, :integer, :limit =>1,:comment => "配番貨物_亜鉛鉱"
    add_column :machines ,:cargo_class05, :integer, :limit =>1,:comment => "配番貨物_ｺｰｸｽ"
    add_column :machines ,:cargo_class07, :integer, :limit =>1,:comment => "配番貨物_銅精鉱"
    add_column :machines ,:cargo_class98, :integer, :limit =>1,:comment => "配番貨物_コンテナ"
    add_column :machines ,:cargo_class17, :integer, :limit =>1,:comment => "配番貨物_スクラップ"
  end
end
