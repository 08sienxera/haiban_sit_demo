# coding: utf-8
class UserHolidayApp < ApplicationRecord
  belongs_to :user
  extend Common::Func
  default_scope {where(:deleted_at => nil)}

  # 休暇種別リスト
  HType = [["公休","2"],["年休","3"],["組休","4"],["振休","5"],["育休","6"],["忌引","7"],["結婚","8"],["看護","9"],["介護","10"],["公傷","11"],["特休","12"],["病欠","13"]]
  # 申請承認区分リスト
  Sts = [["未承認","0"],["承認済","1"],["差戻","2"],["休日対応実施","9"]]



  #
  #===入力画面フォームの生成
  def self.set_input_form(key)
    form = Common::CommonClass.new(key)
    user_list = User.getdatalist({:key=>:id,:text=>:name,:order=>:id,:all=>''})
    form.setparams("user_id",{"title"=>self.human_attribute_name(:user_id),"type"=>"select",'size'=>"8","maxlength"=>"8","inputFlg"=>1,"essFlg"=>1,"align"=>"L",
      "list"=>user_list})
    form.setparams("holiday",{"title"=>self.human_attribute_name(:holiday),"type"=>"textD",'size'=>"11","maxlength"=>"10","inputFlg"=>1,"essFlg"=>1,"align"=>"L"})
    form.setparams("h_type",{"title"=>self.human_attribute_name(:h_type),"type"=>"select",'size'=>"8","maxlength"=>"8","inputFlg"=>1,"essFlg"=>1,"align"=>"L",
      "list"=>HType})
    form.setparams("at_work",{"title"=>self.human_attribute_name(:at_work),"type"=>"select",'size'=>"2","maxlength"=>"2","inputFlg"=>1,"essFlg"=>0,"align"=>"C",
      "list"=>KAFUKA_LIST})
    form.setparams("app_at",{"title"=>self.human_attribute_name(:app_at),"type"=>"textDT",'size'=>"16","maxlength"=>"15","inputFlg"=>1,"essFlg"=>0,"align"=>"C","format"=>"%Y/%m/%d %H:%M"})
    form.setparams("sts",{"title"=>self.human_attribute_name(:sts),"type"=>"select",'size'=>"2","maxlength"=>"2","inputFlg"=>1,"essFlg"=>1,"align"=>"C",
      "list"=>Sts})
    form.setparams("authorizer_id",{"title"=>self.human_attribute_name(:authorizer_id),"type"=>"select",'size'=>"8","maxlength"=>"8","inputFlg"=>1,"essFlg"=>0,"align"=>"L",
      "list"=>user_list})
    form.setparams("authorizer_name",{"title"=>self.human_attribute_name(:authorizer_name),"type"=>"textJ",'size'=>"20","maxlength"=>"32","inputFlg"=>1,"essFlg"=>0,"align"=>"L"})
    form.setparams("approval_at",{"title"=>self.human_attribute_name(:approval_at),"type"=>"textDT",'size'=>"16","maxlength"=>"15","inputFlg"=>1,"essFlg"=>0,"align"=>"C","format"=>"%Y/%m/%d %H:%M"})
    form.setparams('reason',{'title'=>self.human_attribute_name(:reason),'type'=>'textAria','rows'=>'1','cols'=>'80','inputFlg'=>1,'essFlg'=>0,'align'=>'L'})
    form.setparams("origin_date",{"title"=>self.human_attribute_name(:origin_date),"type"=>"textD",'size'=>"11","maxlength"=>"10","inputFlg"=>1,"essFlg"=>0,"align"=>"L"})
    form.setparams("user_holiday_app_id",{"title"=>self.human_attribute_name(:user_holiday_app_id),"type"=>"textN",'size'=>"9","maxlength"=>"8","inputFlg"=>1,"essFlg"=>0,"align"=>"R"})
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
    %w[reason].each{|pkey| form.unsetparams(pkey)}
    form.set_all_param("inputFlg",0)
    form.set_all_param("essFlg",0)

    form.setparams('id',{'title'=>'ID','type'=>'hidden','size'=>'20','maxlength'=>'16','inputFlg'=>0,'essFlg'=>0,'align'=>'R','noserch'=>"1"})
    form.set_index('id',0)
    form.setparam('user_id','link',{:action=>:edit,:id=>'id'})
    return form
  end
  #
  #===休暇者リスト
  def self.get_holiday_4_assignment_list(t_date,t_user=nil?,is_approvaled=true)
    ret_data = {}
    where = ["holiday=?",t_date]
    unless t_user.blank?
      where[0] << " and user_id in (?)"
      where << t_user
    end
    if is_approvaled
      where[0] << " and sts=1"
    end
    data_tbl = self.select(:user_id,:h_type,:at_work).where(where)
    data_tbl.each{|dataline|ret_data[dataline[:user_id]] = {
      :h_type=>dataline[:h_type],
      :h_type_str=>list_to_str(HType,dataline[:h_type].to_s),
      :at_work=>dataline[:at_work],
      :at_work_str=>list_to_str(KAFUKA_MARK,dataline[:at_work].to_s)
      } }
    return ret_data
  end
end
