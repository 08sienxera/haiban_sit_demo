# coding: utf-8
class UserAuth < ApplicationRecord
  extend Common::Func
  default_scope {where(:deleted_at => nil)}
  belongs_to :user, primary_key: :login_id, foreign_key: :login_id, :optional => true
  
  # 機能リスト Feature list
  AuthList = [:view_boards,:lunch_orders,:boards,:vacations,:result_assignment,:cargo_requests,:cargos,:wk_assignment,:sagyo_request,:cargo_request_head_count,:cargo_head_count,:p_orver_time_sheet,:cargo_worker_schedule,:cargo_schedule,:time_sheet,:work_daily_sheet,:time_card,:cargo_result,:sagyo_haiban,:daily_cargo_work_result,:monthly_cargo_work_result,:tax_free_machines_pdf,:cargo_worker_result,:lunch_summary,:work_time_summary,:cargo_work_detail,:worker_work_summary]

  #
  #===入力画面フォームの生成 Generation of input screen form
  def self.set_input_form(key)
    form = Common::CommonClass.new(key)
    user_list = User.getdatalist({:key=>:login_id,:text=>:name,:where=>{:auth_flg=>[2,3]},:order=>:login_id})
    form.setparams("login_no",{"title"=>User.human_attribute_name(:login_id),'type'=>'textA','size'=>'20','maxlength'=>'16','inputFlg'=>0,'essFlg'=>0,"field"=>"login_id","sp_option"=>"no_db"})
    form.setparams("login_id",{"title"=>self.human_attribute_name(:login_id),"type"=>"select",'size'=>"10","maxlength"=>"8","inputFlg"=>1,"essFlg"=>1,"align"=>"L",
      "list"=>user_list})
    AuthList.each{|key|
      form.setparams("#{key}",{"title"=>self.human_attribute_name(key),"type"=>"radio",'size'=>"2","maxlength"=>"2","inputFlg"=>1,"essFlg"=>1,"align"=>"C",
        "list"=>KAFUKA_MARK,"list_row_num"=>2,"defVal"=>"0"})
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
    form = self.set_input_form(key)
    return form
  end
  #
  #===一覧画面フォームの生成 Generate viewing screen form
  def self.set_list_form(key)
    form = self.set_input_form(key)
    AuthList.each{|pkey| form.unsetparams("#{pkey}")}
    form.set_all_param("inputFlg",0)
    form.set_all_param("essFlg",0)
    form.setparams('id',{'title'=>'ID','type'=>'hidden','size'=>'20','maxlength'=>'16','inputFlg'=>0,'essFlg'=>0,'align'=>'R','noserch'=>"1"})
    form.set_index('id',0)
    form.setparam('login_id','link',{:action=>:edit,:id=>'id'})
    #CompetenceKey.each{|key|form.setparam("competence_#{key}",'list',SCompetenceValue)}
    return form
  end


end
