# coding: utf-8
class LunchLocation < ApplicationRecord
  has_many :lunch_menu, lambda{ order("desp_index asc") }
  extend Common::Func
  default_scope {where(:deleted_at => nil)}

  #
  #===入力画面フォームの生成 Generation of input screen form
  def self.set_input_form(key)
    form = Common::CommonClass.new(key)
    form.setparams("s_name",{"title"=>self.human_attribute_name(:s_name),"type"=>"textJ",'size'=>"18","maxlength"=>"16","inputFlg"=>1,"essFlg"=>1,"align"=>"L"})
    form.setparams("name",{"title"=>self.human_attribute_name(:name),"type"=>"textJ",'size'=>"30","maxlength"=>"32","inputFlg"=>1,"essFlg"=>1,"align"=>"L"})
    form.setparams("note",{"title"=>self.human_attribute_name(:note),"type"=>"textJ",'size'=>"30","maxlength"=>"128","inputFlg"=>1,"essFlg"=>0,"align"=>"L"})
    form.setparams("desp_index",{"title"=>self.human_attribute_name(:desp_index),"type"=>"textN",'size'=>"10","maxlength"=>"9","inputFlg"=>1,"essFlg"=>1,"align"=>"R"})
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
    form.setparams('id',{'title'=>'ID','type'=>'hidden','size'=>'20','maxlength'=>'16','inputFlg'=>0,'essFlg'=>0,'align'=>'R','noserch'=>"1"})
    form.set_index('id',0)
    return form
  end
  #
  #===一覧画面フォームの生成 Generate list screen form
  def self.set_list_form(key)
    form = self.set_input_form(key)
    form.set_all_param("inputFlg",0)
    form.set_all_param("essFlg",0)

    form.setparams('id',{'title'=>'ID','type'=>'hidden','size'=>'20','maxlength'=>'16','inputFlg'=>0,'essFlg'=>0,'align'=>'R','noserch'=>"1"})
    form.set_index('id',0)
    form.setparam('s_name','link',{:action=>:edit,:id=>'id'})
    return form
  end
end
