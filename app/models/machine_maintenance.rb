# coding: utf-8
class MachineMaintenance < ApplicationRecord
  extend Common::Func
  default_scope {where(:deleted_at => nil)}
  belongs_to :machine

  # 分類
  MaintenancType = [["定期点検","1"],["故障修理","2"]]

  #
  #===入力画面フォームの生成
  def self.set_input_form(key)
    form = Common::CommonClass.new(key)
    machine_list = Machine.getdatalist({:key=>:id,:text=>:name,:order=>:cd,:where=>{:maintenance=>1}})
    form.setparams("machine_id",{"title"=>self.human_attribute_name(:machine_id),"type"=>"select",'size'=>"12","maxlength"=>"12","inputFlg"=>1,"essFlg"=>1,"align"=>"L",
      "list"=>machine_list})
    form.setparams("maintenanc_type",{"title"=>self.human_attribute_name(:maintenanc_type),"type"=>"radio",'size'=>"12","maxlength"=>"12","inputFlg"=>1,"essFlg"=>1,"align"=>"L",
      "list"=>MaintenancType,"defVal"=>1})
    form.setparams("s_date",{"title"=>self.human_attribute_name(:s_date),"type"=>"textD",'size'=>"11","maxlength"=>"10","inputFlg"=>1,"essFlg"=>1,"align"=>"L","format"=>"%Y/%m/%d"})
    form.setparams("e_date",{"title"=>self.human_attribute_name(:e_date),"type"=>"textD",'size'=>"11","maxlength"=>"10","inputFlg"=>1,"essFlg"=>0,"align"=>"L","format"=>"%Y/%m/%d"})
    form.setparams("note",{"title"=>self.human_attribute_name(:note),"type"=>"textJ",'size'=>"50","maxlength"=>"128","inputFlg"=>1,"essFlg"=>0,"align"=>"L"})
    form.setparams("expense",{"title"=>self.human_attribute_name(:expense),"type"=>"textN",'size'=>"10","maxlength"=>"8","inputFlg"=>1,"essFlg"=>0,"align"=>"R"})
    form.setparams("representative",{"title"=>self.human_attribute_name(:representative),"type"=>"textJ",'size'=>"20","maxlength"=>"32","inputFlg"=>1,"essFlg"=>0,"align"=>"L"})
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
    form.setparam('note','viewMax',20)

    form.setparams('id',{'title'=>'ID','type'=>'hidden','size'=>'20','maxlength'=>'16','inputFlg'=>0,'essFlg'=>0,'align'=>'R','noserch'=>"1"})
    form.set_index('id',0)
    form.setparam('machine_id','link',{:action=>:edit,:id=>'id'})
    return form
  end
  #
  #====メンテナンス中マシンリスト
  def self.get_holiday_4_assignment_list(t_date)
    ret_data = {}
    where = ["(? between s_date and e_date) Or (s_date <= ? And e_date is null)",t_date,t_date]
    data_tbl = self.where(where)
    data_tbl.each{|dataline|ret_data[dataline[:machine_id]] = dataline }
    return ret_data
  end
  #
  #====メンテナンス予定リスト
  def self.get_schedule_4_assignment_list
    ret_data = {}
    data_tbl = self.where(:s_date=>[(Date.today+1)..(Date.today+30)])
    data_tbl.each{|dataline|
      ret_data[dataline[:machine_id]] ||=[]
      msg = ""
      msg << dataline[:s_date].strftime("%m/%d")
      if dataline[:e_date].present? && dataline[:s_date] < dataline[:e_date]
        msg << "～#{dataline[:e_date]-dataline[:s_date]+1}日間"
      end
      msg << dataline[:note]
      ret_data[dataline[:machine_id]] << msg
    }
    return ret_data
  end
end
