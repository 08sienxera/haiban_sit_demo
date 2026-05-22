# coding: utf-8
class CargoCdMaster < ApplicationRecord
  extend Common::Func
  self.primary_key = :work_cd
  belongs_to :cargo_class_master, class_name: 'CargoClassMaster', primary_key: :cargo_class,foreign_key: :cargo_class
  has_many :cargo, class_name: 'Cargo', foreign_key: :work_cd
  default_scope {where(:deleted_at => nil)}


    #===入力画面フォームの生成 Generation of input screen form
    def self.set_input_form(key)
      form = Common::CommonClass.new(key)
      form.setparams("work_cd",{"title"=>self.human_attribute_name(:work_cd),"type"=>"textA",'size'=>"6","maxlength"=>"4","inputFlg"=>1,"essFlg"=>1,"align"=>"L"})
      form.setparams("cargo_class",{"title"=>self.human_attribute_name(:cargo_class),"type"=>"textA",'size'=>"6","maxlength"=>"2","inputFlg"=>1,"essFlg"=>0,"align"=>"L"})
      form.setparams("cargo_class2",{"title"=>self.human_attribute_name(:cargo_class2),"type"=>"textA",'size'=>"10","maxlength"=>"8","inputFlg"=>1,"essFlg"=>0,"align"=>"L"})
      form.setparams("cargo_class3",{"title"=>self.human_attribute_name(:cargo_class3),"type"=>"textA",'size'=>"10","maxlength"=>"8","inputFlg"=>1,"essFlg"=>0,"align"=>"L"})
      form.setparams("cargo_class4",{"title"=>self.human_attribute_name(:cargo_class4),"type"=>"textA",'size'=>"10","maxlength"=>"8","inputFlg"=>1,"essFlg"=>0,"align"=>"L"})
      form.setparams("cargo_class5",{"title"=>self.human_attribute_name(:cargo_class5),"type"=>"textA",'size'=>"10","maxlength"=>"8","inputFlg"=>1,"essFlg"=>0,"align"=>"L"})
      form.setparams("cargo_class6",{"title"=>self.human_attribute_name(:cargo_class6),"type"=>"textA",'size'=>"10","maxlength"=>"8","inputFlg"=>1,"essFlg"=>0,"align"=>"L"})
      form.setparams("cargo_class7",{"title"=>self.human_attribute_name(:cargo_class7),"type"=>"textA",'size'=>"10","maxlength"=>"8","inputFlg"=>1,"essFlg"=>0,"align"=>"L"})
      form.setparams("cargo_class8",{"title"=>self.human_attribute_name(:cargo_class8),"type"=>"textA",'size'=>"10","maxlength"=>"8","inputFlg"=>1,"essFlg"=>0,"align"=>"L"})
      form.setparams("cargo_class9",{"title"=>self.human_attribute_name(:cargo_class9),"type"=>"textA",'size'=>"10","maxlength"=>"8","inputFlg"=>1,"essFlg"=>0,"align"=>"L"})
      form.setparams("cargo_class11",{"title"=>self.human_attribute_name(:cargo_class11),"type"=>"textA",'size'=>"6","maxlength"=>"4","inputFlg"=>1,"essFlg"=>0,"align"=>"L"})
      form.setparams("cargo_class12",{"title"=>self.human_attribute_name(:cargo_class12),"type"=>"textA",'size'=>"6","maxlength"=>"4","inputFlg"=>1,"essFlg"=>0,"align"=>"L"})
      form.setparams("cargo_name",{"title"=>self.human_attribute_name(:cargo_name),"type"=>"textJ",'size'=>"32","maxlength"=>"64","inputFlg"=>1,"essFlg"=>0,"align"=>"L"})
      form.setparams("cargo_name_s",{"title"=>self.human_attribute_name(:cargo_name_s),"type"=>"textJ",'size'=>"32","maxlength"=>"32","inputFlg"=>1,"essFlg"=>0,"align"=>"L"})
      form.setparams("zenno_cd",{"title"=>self.human_attribute_name(:zenno_cd),"type"=>"textN",'size'=>"6","maxlength"=>"4","inputFlg"=>1,"essFlg"=>0,"align"=>"L"})
      form.setparams("zenno_name",{"title"=>self.human_attribute_name(:zenno_name),"type"=>"textJ",'size'=>"6","maxlength"=>"4","inputFlg"=>1,"essFlg"=>0,"align"=>"L"})
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
      form = self.set_input_form(key)
      return form
    end
    #===一覧フォームの生成 Generate list form
    def self.set_list_form(key)
      form = self.set_input_form(key)
      form.set_all_param("inputFlg",0)
      form.set_all_param("essFlg",0)
      form.setparams('id',{'title'=>'ID','type'=>'hidden','size'=>'20','maxlength'=>'16','inputFlg'=>0,'essFlg'=>0,'align'=>'R','noserch'=>"1"})
      form.set_index('id',0)
      form.setparam('work_cd','link',{:action=>:edit,:id=>'id'})
      return form

  end
  

end
