# coding: utf-8
class Machine < ApplicationRecord
  has_many :machine_maintenance, lambda{ order("s_date desc") }
  extend Common::Func
  include ColorConverter
  before_update :convert_color
    
  default_scope {where(:deleted_at => nil)}
  # 機械種別 Machine type
  MType = [["ローダ","ld"],["バックホー","bh"],["船内ローダ","sl"],["ブル","bl"],["リフト","lf"],["SC","sc"],["バス","bs"],["その他","ot"]]
  # 実績集計区分 Actual aggregation category
  ACategory = [["トラクタショベル","A"],["クレーン","C"],["ドーザ","D"],["フォークリフト","F"],["ストラドルキャリヤー","S"],["集計なし","N"]]
  # 対象値リスト target value list
  Target  = [["対象","1"],["対象外","0"]]
  # 配番停止リスト Numbering stop list
  UMaintenance = [["配番対象","0"],["配番停止","1"]]
  # 配番貨物レベル Assigned cargo level
  CargoClass = [["優先","2"],["可","1"],["指定無","0"],["不可","-1"]]
  #
  #===入力画面フォームの生成 Generation of input screen form
  def self.set_input_form(key)
    form = Common::CommonClass.new(key)
    branch_list = Branche.getdatalist({:key=>:cd,:text=>:name,:order=>:desp_index,:where=>{:applicable=>Applicable.get_applicable(1)},:all=>'所属なし'})
    form.setparams("cd",{"title"=>self.human_attribute_name(:cd),"type"=>"textJ",'size'=>"18","maxlength"=>"16","inputFlg"=>1,"essFlg"=>1,"align"=>"L"})
    form.setparams("name",{"title"=>self.human_attribute_name(:name),"type"=>"textJ",'size'=>"18","maxlength"=>"16","inputFlg"=>1,"essFlg"=>1,"align"=>"L"})
    form.setparams("m_type",{"title"=>self.human_attribute_name(:m_type),"type"=>"select",'size'=>"2","maxlength"=>"2","inputFlg"=>1,"essFlg"=>1,"align"=>"C",
      "list"=>MType,"defVal"=>"ot"})
    form.setparams("branch_cd",{"title"=>self.human_attribute_name(:branch_cd),"type"=>"select",'size'=>"8","maxlength"=>"8","inputFlg"=>1,"essFlg"=>0,"align"=>"L",
      "list"=>branch_list})
    form.setparams("color",{"title"=>self.human_attribute_name(:color),"type"=>"textColor",'size'=>"9","maxlength"=>"7","inputFlg"=>1,"essFlg"=>0,"align"=>"L"})
    form.setparams("a_category",{"title"=>self.human_attribute_name(:a_category),"type"=>"select",'size'=>"2","maxlength"=>"2","inputFlg"=>1,"essFlg"=>1,"align"=>"C",
      "list"=>ACategory,"defVal"=>"N"})
    form.setparams("light_oil",{"title"=>self.human_attribute_name(:light_oil),"type"=>"radio",'size'=>"2","maxlength"=>"2","inputFlg"=>1,"essFlg"=>1,"align"=>"C",
      "list"=>Target,"defVal"=>"0"})
    form.setparams("maintenance",{"title"=>self.human_attribute_name(:maintenance),"type"=>"radio",'size'=>"2","maxlength"=>"2","inputFlg"=>1,"essFlg"=>1,"align"=>"C",
      "list"=>Target,"defVal"=>"0"})
    form.setparams("u_maintenance",{"title"=>self.human_attribute_name(:u_maintenance),"type"=>"radio",'size'=>"2","maxlength"=>"2","inputFlg"=>1,"essFlg"=>1,"align"=>"C",
      "list"=>UMaintenance,"defVal"=>"0"})
    form.setparams("start_day",{"title"=>self.human_attribute_name(:start_day),"type"=>"textD",'size'=>"11","maxlength"=>"10","inputFlg"=>1,"essFlg"=>0,"align"=>"L","format"=>"%Y/%m/%d"})
    form.setparams("last_mainte_day",{"title"=>self.human_attribute_name(:last_mainte_day),"type"=>"textD",'size'=>"11","maxlength"=>"10","inputFlg"=>1,"essFlg"=>0,"align"=>"L","format"=>"%Y/%m/%d"})
    form.setparams("maker",{"title"=>self.human_attribute_name(:maker),"type"=>"textJ",'size'=>"20","maxlength"=>"32","inputFlg"=>1,"essFlg"=>0,"align"=>"L"})
    1.upto(3){|wi|
      form.setparams("wk_place#{wi}",{"title"=>self.human_attribute_name("wk_place#{wi}"),"type"=>"textJ",'size'=>"9","maxlength"=>"8","inputFlg"=>1,"essFlg"=>0,"align"=>"L"})
    }
    %w(09 23_3818 23_3816 12 01 06 05 07 98 17).each{|no|
      form.setparams("cargo_class#{no}",{"title"=>self.human_attribute_name("cargo_class#{no}"),"type"=>"radio",'size'=>"2","maxlength"=>"8","inputFlg"=>1,"essFlg"=>0,"align"=>"C",
        "list"=>CargoClass,"defVal"=>"0"})
    }
    return form
  end
  #
  #===更新画面フォームの生成 Generate update screen form
  def self.set_edit_form(key)
    return self.set_input_form(key)
  end
  #
  #===CSVフォームの生成 Generate CSV form
  def self.set_csv_form(key)
    return self.set_input_form(key)
  end
  #
  #===一覧画面フォームの生成 Generate list screen form
  def self.set_list_form(key)
    form = self.set_input_form(key)
    %w[light_oil maintenance].each{|pkey| form.setparam(pkey,"type","select")}
    %w[color  wk_place3].each{|pkey| form.unsetparams(pkey)}
    %w(09 23_3818 23_3816 12 01 06 05 07 98 17).each{|no| form.unsetparams("cargo_class#{no}")}
    form.set_all_param("inputFlg",0)
    form.set_all_param("essFlg",0)

    form.setparams('id',{'title'=>'ID','type'=>'hidden','size'=>'20','maxlength'=>'16','inputFlg'=>0,'essFlg'=>0,'align'=>'R','noserch'=>"1"})
    form.set_index('id',0)
    form.setparam('cd','link',{:action=>:edit,:id=>'id'})
    return form
  end
  #
  #===配番用機械リスト Machine list for numbering
  def self.get_assignment_list(t_date)
    assignment_list = {} ; names = {} ; colors=[]
    holiday_list = MachineMaintenance.get_holiday_4_assignment_list(t_date)
    schedule_list = MachineMaintenance.get_schedule_4_assignment_list()
    data_tbl = self.all.order(:cd)
    MType.each{|text,type_cd| assignment_list[type_cd] = []}
    data_tbl.each{|dataline|
      assignment_data = {}
      [:id,:cd,:name,:m_type,:branch_cd,:color,:start_day,:u_maintenance,
       :wk_place1,:wk_place2,:wk_place3,:cargo_class09,:cargo_class23_3818,:cargo_class23_3816,
       :cargo_class12,:cargo_class01,:cargo_class06,:cargo_class05,:cargo_class07,:cargo_class98,
       :cargo_class17].each{|key| assignment_data[key] = dataline[key]}
      if holiday_list.has_key?(dataline[:id])
        assignment_data[:mainte] = holiday_list[dataline[:id]]
      else
        assignment_data[:mainte] = nil
      end
      if schedule_list.has_key?(dataline[:id])
        assignment_data[:schedule] = schedule_list[dataline[:id]]
      else
        assignment_data[:schedule] = nil
      end
      assignment_list[dataline[:m_type]] << assignment_data
      names[dataline[:cd]] = dataline[:name]
      colors << dataline[:color]
    }unless data_tbl.blank?
    return [assignment_list,names,colors.uniq.compact_blank]
  end

end
