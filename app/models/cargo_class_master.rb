# coding: utf-8
class CargoClassMaster < ApplicationRecord
  extend Common::Func
  self.primary_key = :cargo_class
  has_many :cargo_cd_masters, class_name: 'CargoCdMaster', foreign_key: :cargo_class
  default_scope {where(:deleted_at => nil)}


    #===入力画面フォームの生成
  def self.set_input_form(key)
    form = Common::CommonClass.new(key)
    form.setparams("cargo_class",{"title"=>self.human_attribute_name(:cargo_class),"type"=>"textA",'size'=>"4","maxlength"=>"2","inputFlg"=>1,"essFlg"=>1,"align"=>"C"})
    form.setparams("name",{"title"=>self.human_attribute_name(:name),"type"=>"textJ",'size'=>"32","maxlength"=>"64","inputFlg"=>1,"essFlg"=>0,"align"=>"L"})
    form.setparams("name_s",{"title"=>self.human_attribute_name(:name_s),"type"=>"textJ",'size'=>"32","maxlength"=>"64","inputFlg"=>1,"essFlg"=>0,"align"=>"L"})
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
    form.setparam('cargo_class','link',{:action=>:edit,:id=>'id'})
    return form
  end
  

end
