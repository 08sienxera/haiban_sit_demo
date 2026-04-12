# coding: utf-8
class Applicable < ApplicationRecord
  extend Common::Func
  default_scope {where(:deleted_at => nil)}
  # グループセクション　
  # グループ or 作業員
  SectionList = [["グループ","1"],["作業員","2"]] 

  #
  #===入力画面フォームの生成
  def self.set_input_form(key)
    form = Common::CommonClass.new(key)
    form.setparams("section",{"title"=>self.human_attribute_name(:section),"type"=>"select",'size'=>"8","maxlength"=>"8","inputFlg"=>1,"essFlg"=>1,"align"=>"L",
      "list"=>SectionList})
    form.setparams("applicable",{"title"=>self.human_attribute_name(:applicable),"type"=>"textD",'size'=>"11","maxlength"=>"10","inputFlg"=>1,"essFlg"=>1,"align"=>"L","format"=>"%Y/%m/%d"})
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
    return self.set_input_form(key)
  end
  #
  #===一覧画面フォームの生成
  def self.set_list_form(key)
    form = self.set_input_form(key)
    form.set_all_param("inputFlg",0)
    form.set_all_param("essFlg",0)
    form.setparams('id',{'title'=>'ID','type'=>'hidden','size'=>'20','maxlength'=>'16','inputFlg'=>0,'essFlg'=>0,'align'=>'R','noserch'=>"1"})
    form.set_index('id',0)
    form.setparam('applicable','link',{:action=>:edit,:id=>'id'})
    return form
  end
  #
  #===適用改定日の取得
  def self.get_applicable(section,t_date=Date.today)
    dataline = self.where(["section=? and applicable <= ?",section,t_date]).order(:applicable=>:desc).first
    return dataline ? dataline[:applicable] : nil
  end
  #
  #===改定日リストの生成
  def self.get_applicable_list(section)
    dtatbl = self.where(:section=>section).order(:applicable=>:desc)
    ret = []
    dtatbl.each{|dataline|
      txt = dataline[:applicable].strftime("%Y/%m/%d")
      ret << [txt,txt]
    }
    return ret
  end

end
