# coding: utf-8
class LunchMenu < ApplicationRecord
  belongs_to :lunch_vendor
  extend Common::Func
  default_scope {where(:deleted_at => nil)}
  #
  #===入力画面フォームの生成 Generation of input screen form
  def self.set_input_form(key)
    form = Common::CommonClass.new(key)
    vendors = LunchVendor.getdatalist({:key=>:id,:text=>:name,:order=>:desp_index,:all=>''})
    form.setparams("lunch_vendor_id",{"title"=>self.human_attribute_name(:lunch_vendor_id),"type"=>"select",'size'=>"8","maxlength"=>"8","inputFlg"=>1,"essFlg"=>1,"align"=>"L",
      "list"=>vendors})
      form.setparams("name",{"title"=>self.human_attribute_name(:name),"type"=>"textJ",'size'=>"18","maxlength"=>"16","inputFlg"=>1,"essFlg"=>1,"align"=>"L"})
      form.setparams("s_name",{"title"=>self.human_attribute_name(:s_name),"type"=>"textJ",'size'=>"8","maxlength"=>"6","inputFlg"=>1,"essFlg"=>0,"align"=>"L"})
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
    form.setparam('name','link',{:action=>:edit,:id=>'id'})
    return form
  end
end
