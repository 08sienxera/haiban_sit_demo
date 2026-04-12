# coding: utf-8
class CargoRequest < ApplicationRecord
  extend Common::Func
  default_scope {where(:deleted_at => nil)}

  has_one :cargo
  # 作業人数合計　集計フィールドリスト
  WokerNumKey = %w[fm_m dm_m wm_m cr_m ld_m ld_s bh_m bh_s sl_m sl_s bl_m bl_s lf_m lf_s sc_m sc_s ot_m hd_w db_w hs_w sn_w eg_w ot_w wk_w]
  # 作業区分リスト

  WorkClasses = [["本船","1"],["沿岸","2"],["休み","9"]]
  # 揚積区分リスト
  IOFlg = [["",""],["揚","1"],["積","2"],["揚積","3"],["その他","4"]]
  # 汚れ作業区分リスト
  DirtFlg = [["","0"],["汚れ","1"]]
  # 配番状況確定区分リスト
  EstaFlg = [["","0"],["配番中","1"],["成立","2"],["不成立","9"]]
  # 部署リスト
  Departments = [["港運営業第一課","2"],["コンテナ木材課","9"],["管理課","11"]]
  # 担当作業リスト
  WkClasses = {""=>"","fm"=>"FM","dm"=>"DM","wm"=>"WM","cr"=>"ｸﾚｰﾝ","ld"=>"ローダ","bh"=>"ﾊﾞｯｸﾎｰ","sl"=>"船内ﾛｰﾀﾞ","bl"=>"ブル","lf"=>"リフト","sc"=>"SC","tl"=>"TL","ot"=>"他作業","hd"=>"ハンドル","db"=>"土場作業","hs"=>"配車作業","sn"=>"船内作業","eg"=>"沿岸作業"}
  #
  #===入力画面フォームの生成
  def self.set_input_form(key)
    form = Common::CommonClass.new(key)
    form.setparams('work_date',{'title'=>self.human_attribute_name(:work_date),'type'=>'hidden','size'=>'11','maxlength'=>'10','inputFlg'=>1,'essFlg'=>1,'align'=>'C'})
    form.setparams("department_cd",{"title"=>self.human_attribute_name(:department_cd),"type"=>"textA",'size'=>"4","maxlength"=>"2","inputFlg"=>1,"essFlg"=>0,"align"=>"L"})
    form.setparams("department_nm",{"title"=>self.human_attribute_name(:department_nm),"type"=>"textJ",'size'=>"25","maxlength"=>"20","inputFlg"=>1,"essFlg"=>0,"align"=>"L"})
    form.setparams("work_class",{"title"=>self.human_attribute_name(:work_class),"type"=>"select",'size'=>"1","maxlength"=>"1","inputFlg"=>1,"essFlg"=>1,"align"=>"C",
      "list"=>WorkClasses})
    form.setparams("move_no",{"title"=>self.human_attribute_name(:move_no),"type"=>"textA",'size'=>"9","maxlength"=>"8","inputFlg"=>1,"essFlg"=>0,"align"=>"L"})
    form.setparams("move_no2",{"title"=>self.human_attribute_name(:move_no2),"type"=>"textA",'size'=>"9","maxlength"=>"8","inputFlg"=>1,"essFlg"=>0,"align"=>"L"})
    form.setparams("serial_no",{"title"=>self.human_attribute_name(:serial_no),"type"=>"textN",'size'=>"3","maxlength"=>"2","inputFlg"=>1,"essFlg"=>1,"align"=>"R"})
    form.setparams("work_no",{"title"=>self.human_attribute_name(:work_no),"type"=>"textN",'size'=>"3","maxlength"=>"3","inputFlg"=>1,"essFlg"=>1,"align"=>"R"})
    form.setparams("work_name",{"title"=>self.human_attribute_name(:work_name),"type"=>"textJ",'size'=>"40","maxlength"=>"30","inputFlg"=>1,"essFlg"=>1,"align"=>"L"})
    form.setparams("work_cd",{"title"=>self.human_attribute_name(:work_cd),"type"=>"textA",'size'=>"5","maxlength"=>"4","inputFlg"=>1,"essFlg"=>0,"align"=>"L"})
    form.setparams("cargo_name",{"title"=>self.human_attribute_name(:cargo_name),"type"=>"textJ",'size'=>"40","maxlength"=>"20","inputFlg"=>1,"essFlg"=>0,"align"=>"L"})
    form.setparams("io_flg",{"title"=>self.human_attribute_name(:io_flg),"type"=>"select",'size'=>"1","maxlength"=>"1","inputFlg"=>1,"essFlg"=>0,"align"=>"C",
      "list"=>IOFlg})
    form.setparams("quantity",{"title"=>self.human_attribute_name(:quantity),"type"=>"textJ",'size'=>"10","maxlength"=>"8","inputFlg"=>1,"essFlg"=>0,"align"=>"L"})
    form.setparams("work_place",{"title"=>self.human_attribute_name(:work_place),"type"=>"textJ",'size'=>"10","maxlength"=>"8","inputFlg"=>1,"essFlg"=>0,"align"=>"C"})
    form.setparams("i_time",{"title"=>self.human_attribute_name(:i_time),"type"=>"textT",'size'=>"5","maxlength"=>"5","inputFlg"=>1,"essFlg"=>0,"align"=>"C"})
    form.setparams("s_time",{"title"=>self.human_attribute_name(:s_time),"type"=>"textT",'size'=>"5","maxlength"=>"5","inputFlg"=>1,"essFlg"=>0,"align"=>"C"})
    form.setparams("e_time",{"title"=>self.human_attribute_name(:e_time),"type"=>"textT",'size'=>"5","maxlength"=>"5","inputFlg"=>1,"essFlg"=>0,"align"=>"C"})
    form.setparams("dirt_flg",{"title"=>self.human_attribute_name(:dirt_flg),"type"=>"check_one",'size'=>"1","maxlength"=>"1","inputFlg"=>1,"essFlg"=>0,"align"=>"C","label"=>"汚れ有り"})
    form.setparams("machine_nm",{"title"=>self.human_attribute_name(:machine_nm),"type"=>"textJ",'size'=>"10","maxlength"=>"10","inputFlg"=>1,"essFlg"=>0,"align"=>"L"})
    WokerNumKey.each{|key| form.setparams(key,{"title"=>self.human_attribute_name(key),"type"=>"textN",'size'=>"3","maxlength"=>"2","inputFlg"=>1,"essFlg"=>0,"align"=>"R","onchange"=>(key=="wk_w" ? nil : "calcCount()")})}
    form.setparams("note",{"title"=>self.human_attribute_name(:note),"type"=>"textJ",'size'=>"60","maxlength"=>"50","inputFlg"=>1,"essFlg"=>0,"align"=>"L"})
    form.setparams("matter1",{"title"=>self.human_attribute_name(:matter1),"type"=>"textJ",'size'=>"90","maxlength"=>"80","inputFlg"=>1,"essFlg"=>0,"align"=>"L"})
    form.setparams("matter2",{"title"=>self.human_attribute_name(:matter2),"type"=>"textJ",'size'=>"90","maxlength"=>"80","inputFlg"=>1,"essFlg"=>0,"align"=>"L"})
    form.setparams("esta_flg",{"title"=>self.human_attribute_name(:esta_flg),"type"=>"hidden",'size'=>"1","maxlength"=>"1","inputFlg"=>1,"essFlg"=>0,"align"=>"C",
      "list"=>EstaFlg,"defVal"=>"0"})
    return form
  end
  #
  #===更新画面フォームの生成
  def self.set_edit_form(key)
    return self.set_input_form(key)
  end
  #
  #===CSVフォームの生成
  def self.set_csv_form(key)
    form = self.set_input_form(key)
    form.setparam('work_date','type',"textD")
    form.setparam('move_no','exp',"作業区分が「1:本船」の場合必須")
    form.setparam('move_no2','exp',"作業区分が「2:沿岸」の場合必須")

    form.setparam('dirt_flg','type',"select")
    form.setparam('dirt_flg','list',[["該当なし","0"],["汚れ該当","1"]])


    form.unsetparams("esta_flg")
    return form
  end

  def csv_output
    return render :json=>params
    condition = {}
    search_data = session.dig("serch_data","Woker")
    search_applicable = search_data&.dig("applicable") #=> format"2024/07/08"
    if search_data.present?
      condition[:applicable] = Date.parse(search_applicable) if search_applicable.present? # true=>改定日指定 false=>all指定
    else #検索なし
      condition[:applicable] = Applicable.where(:section=>2).order(:applicable=>:desc).first&.applicable
    end
    @my_setting[:def_where] = condition
    super()
  end


end
