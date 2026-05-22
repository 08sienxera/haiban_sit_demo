# coding: utf-8
class Branche < ApplicationRecord
  extend Common::Func
  include ColorConverter
  before_update :convert_color


  default_scope {where(:deleted_at => nil)}
  # 現場作業者のCDリスト Site worker CD list
  WorkerBranchCd = %w[1 2 3 4]
  # 集計の合算対象グループ Groups to be aggregated
  WorkerBranchSum = {"10"=>{:title=>"１課",:target=>%w[1 2]},"20"=>{:title=>"２課",:target=>%w[3 4]}}
  # 対応する集計合算グループ Corresponding aggregation summation group
  WorkerBranchSumKey = {"1"=>"10","2"=>"10","3"=>"20","4"=>"20"}

    

  #
  #===入力画面フォームの生成 Generation of input screen form
  def self.set_input_form(key)
    form = Common::CommonClass.new(key)
    applicables = Applicable.get_applicable_list(1)
    form.setparams("applicable",{"title"=>self.human_attribute_name(:applicable),"type"=>"select",'size'=>"10","maxlength"=>"8","inputFlg"=>1,"essFlg"=>1,"align"=>"L",
      "list"=>applicables,"format"=>"%Y/%m/%d"})
    form.setparams("cd",{"title"=>self.human_attribute_name(:cd),"type"=>"textA",'size'=>"9","maxlength"=>"8","inputFlg"=>1,"essFlg"=>1,"align"=>"L"})
    form.setparams("name",{"title"=>self.human_attribute_name(:name),"type"=>"textJ",'size'=>"18","maxlength"=>"16","inputFlg"=>1,"essFlg"=>1,"align"=>"L"})
    form.setparams("color",{"title"=>self.human_attribute_name(:color),"type"=>"textColor",'size'=>"9","maxlength"=>"7","inputFlg"=>1,"essFlg"=>0,"align"=>"L"})
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
    form.setparam('applicable','type','textD')
    return form
  end
  #
  #===一覧画面フォームの生成 Generate list screen form
  def self.set_list_form(key)
    form = self.set_input_form(key)
    %w[color desp_index].each{|pkey| form.unsetparams(pkey)}
    form.set_all_param("inputFlg",0)
    form.set_all_param("essFlg",0)

    form.setparams('id',{'title'=>'ID','type'=>'hidden','size'=>'20','maxlength'=>'16','inputFlg'=>0,'essFlg'=>0,'align'=>'R','noserch'=>"1"})
    form.set_index('id',0)
    form.setparam('cd','link',{:action=>:edit,:id=>'id'})
    return form
  end
  #
  #===配番用部署リストを返す Return department list for numbering
  def self.get_assignment_list(t_date=Date.today)
    assignment_list = {}
    where = {:applicable=>Applicable.get_applicable(1,t_date)}
    data_tbl = self.where(where).order(:desp_index)
    data_tbl.each{|dataline|
      assignment_data = {}
      [:name,:color].each{|key| assignment_data[key] = dataline[key]}
      assignment_list[dataline[:cd]] = assignment_data
    }unless data_tbl.blank?
    return assignment_list
  end
  #
  #===集計用部署リストを返す Return the department list for aggregation
  def self.get_sum_list(t_date=Date.today)
    sum_list = []
    branch_list = self.getdatalist({:key=>:cd,:text=>:name,:where=>{:applicable=>Applicable.get_applicable(1,t_date),:cd=>WorkerBranchCd},:order=>:desp_index,:type=>"hash"})
    WorkerBranchSum.each{|sum_cd,sum_info|
      sum_list << [sum_info[:title],sum_cd]
      sum_info[:target].each{|cd|
        sum_list << [branch_list[cd],cd]
      }
    }
    return sum_list
  end
  #
  #===部署色リストを返す Return department color list
  def self.get_color_list(t_date=Date.today)
    return self.getdatalist({:key=>:cd,:text=>:color,:where=>{:applicable=>Applicable.get_applicable(1,t_date)},:type=>"hash"})
  end

  #===引数が現場作業者のグループか返す Returns whether the argument is a group of field workers
  def self.is_worker_branche?(branche_cd)
    WorkerBranchCd.include?(branche_cd)    
  end
  
  # スコープ scope
  scope :cargo_work_group, -> { where(:cd=>WorkerBranchCd) } 



end
