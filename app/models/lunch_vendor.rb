# coding: utf-8
class LunchVendor < ApplicationRecord
  has_many :lunch_menu, lambda{ order("desp_index asc") }
  extend Common::Func
  default_scope {where(:deleted_at => nil)}
  
  # 平日公休日フラグリスト
  WhList = [["平日用","0"],["土曜日用","6"],["日曜日用","1"],["祝日用","2"]]

  #
  #===入力画面フォームの生成
  def self.set_input_form(key)
    form = Common::CommonClass.new(key)
    form.setparams("name",{"title"=>self.human_attribute_name(:name),"type"=>"textJ",'size'=>"18","maxlength"=>"16","inputFlg"=>1,"essFlg"=>1,"align"=>"L"})
    form.setparams("s_name",{"title"=>self.human_attribute_name(:s_name),"type"=>"textJ",'size'=>"4","maxlength"=>"3","inputFlg"=>1,"essFlg"=>0,"align"=>"C"})
    form.setparams("wh_flg",{"title"=>self.human_attribute_name(:wh_flg),"type"=>"radio",'size'=>"8","maxlength"=>"8","inputFlg"=>1,"essFlg"=>1,"align"=>"L",
      "list"=>WhList})
      form.setparams("desp_index",{"title"=>self.human_attribute_name(:desp_index),"type"=>"textN",'size'=>"10","maxlength"=>"9","inputFlg"=>1,"essFlg"=>0,"align"=>"R"})
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
    form.setparams('id',{'title'=>'ID','type'=>'hidden','size'=>'20','maxlength'=>'16','inputFlg'=>0,'essFlg'=>0,'align'=>'R','noserch'=>"1"})
    form.set_index('id',0)
    return form
  end
  #
  #===一覧画面フォームの生成
  def self.set_list_form(key)
    form = self.set_input_form(key)
    form.set_all_param("inputFlg",0)
    form.set_all_param("essFlg",0)

    form.setparams('id',{'title'=>'ID','type'=>'hidden','size'=>'20','maxlength'=>'16','inputFlg'=>0,'essFlg'=>0,'align'=>'R','noserch'=>"1"})
    form.set_index('id',0)
    form.setparam('name','link',{:action=>:edit,:id=>'id'})
    return form
  end
  #
  #===カレンダー初期値用リスト作成
  def self.get_def_vendor
    ret = {}
    all_data = self.all.order(:desp_index)
    all_data.each{|dataline|
      ret[dataline[:wh_flg]] = dataline[:id] unless ret.has_key?(dataline[:wh_flg])
      break if ret.size == WhList.size
    }
    return ret
  end
  
end
