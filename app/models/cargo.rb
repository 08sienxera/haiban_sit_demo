# coding: utf-8
class Cargo < ApplicationRecord
  include CargoEditUser

  belongs_to :cargo_request , :optional => true
  has_many :cargo_worker
  belongs_to :cargo_cd_master, class_name: 'CargoCdMaster', primary_key: :work_cd,foreign_key: :work_cd , optional: true
  # has_many :cargo_cd_masters, class_name: 'CargoCdMaster', foreign_key: :cargo_class
  has_many :cargo_machine
  extend Common::Func
  default_scope {where(:deleted_at => nil)}


  # 作業カテゴリリスト Work category list
  WkType = [["FM","fm"],["DM","dm"],["機械","mc"],["ウィンチ","wi"],["取扱者","dr"],["船内／沿岸","wk"]]
  # 技量グループリスト Skill group list
  WkTypeXNumKey = {:fm=>["fm_m"],:dm=>["dm_m"],:wi=>["wm_m","cr_m"],:dr=>["ld_m","ld_s","bh_m","bh_s","sl_m","sl_s","bl_m","bl_s","lf_m","lf_s","sc_m","sc_s","tl_m","tl_s","ot_m"],:wk=>["hd_w","db_w","hs_w","sn_w","eg_w","ot_w"]}
  # 作業人数合計　集計フィールドリスト Total number of workers Summary field list
  WokerNumKey = %w[fm_m dm_m wm_m cr_m ld_m ld_s bh_m bh_s sl_m sl_s bl_m bl_s lf_m lf_s sc_m sc_s tl_m tl_s ot_m hd_w db_w hs_w sn_w eg_w ot_w]
  # 基本出勤時刻 Basic attendance time
  RegularITime = "07:00"
  # 基本開始時刻 basic start time
  RegularSTime = "07:30"
  # 基本終了時刻 basic end time
  RegularETime = "16:30"

  #
  #===コールバック Callbacks
  before_create do
    calc_wk_time
  end
  before_update do
    calc_wk_time
  end
  after_update do
    cargo_request_status_link
  end

  #
  #===入力画面フォームの生成 Generate input screen form
  def self.set_input_form(key)
    form = Common::CommonClass.new(key)
    form.setparams("id",{"title"=>"id","type"=>"hidden",'size'=>"8","maxlength"=>"8","inputFlg"=>1,"essFlg"=>0,"align"=>"R"})
    form.setparams("cargo_request_id",{"title"=>"cargo_request_id","type"=>"hidden",'size'=>"8","maxlength"=>"8","inputFlg"=>1,"essFlg"=>0,"align"=>"R"})
    form.setparams("work_date",{"title"=>self.human_attribute_name(:work_date),"type"=>"textD",'size'=>"11","maxlength"=>"10","inputFlg"=>1,"essFlg"=>1,"align"=>"C","format"=>"%Y/%m/%d"})
    form.setparams("work_no",{"title"=>self.human_attribute_name(:work_no),"type"=>"textN",'style'=>"width:16px;","maxlength"=>"2","inputFlg"=>1,"essFlg"=>1,"align"=>"R","onchange"=>"setVewData(this)"})
    form.setparams("move_no",{"title"=>self.human_attribute_name(:move_no),"type"=>"textA",'style'=>"width:68px;","maxlength"=>"8","inputFlg"=>1,"essFlg"=>1,"align"=>"L","onchange"=>"setVewData(this);loadCargoMaster(this);"})
    form.setparams("desp_index",{"title"=>self.human_attribute_name(:desp_index),"type"=>"hidden",'size'=>"11","maxlength"=>"10","inputFlg"=>1,"essFlg"=>1,"align"=>"R"})
    form.setparams("work_name",{"title"=>self.human_attribute_name(:work_name),"type"=>"textJ",'style'=>"width:100px;","maxlength"=>"32","inputFlg"=>1,"essFlg"=>1,"align"=>"L","onchange"=>"setVewData(this)"})
    form.setparams("work_cd",{"title"=>self.human_attribute_name(:work_cd),"type"=>"textA",'style'=>"width:66px;","maxlength"=>"4","inputFlg"=>1,"essFlg"=>0,"align"=>"L","onchange"=>"setVewData(this)"})
    form.setparams("cargo_name",{"title"=>self.human_attribute_name(:cargo_name),"type"=>"textJ",'style'=>"width:100px;","maxlength"=>"32","inputFlg"=>1,"essFlg"=>0,"align"=>"L","onchange"=>"setVewData(this)"})
    form.setparams("work_place",{"title"=>self.human_attribute_name(:work_place),"type"=>"textJ",'style'=>"width:50px;","maxlength"=>"8","inputFlg"=>1,"essFlg"=>0,"align"=>"C","onchange"=>"setVewData(this)"})
    form.setparams("i_time",{"title"=>self.human_attribute_name(:i_time),"type"=>"textT",'style'=>"width:38px;","maxlength"=>"5","inputFlg"=>1,"essFlg"=>0,"align"=>"C","onchange"=>"setVewData(this)"})
    form.setparams("s_time",{"title"=>self.human_attribute_name(:s_time),"type"=>"textT",'style'=>"width:38px;","maxlength"=>"5","inputFlg"=>1,"essFlg"=>0,"align"=>"C","onchange"=>"setVewData(this)"})
    form.setparams("e_time",{"title"=>self.human_attribute_name(:e_time),"type"=>"textT",'style'=>"width:38px;","maxlength"=>"5","inputFlg"=>1,"essFlg"=>0,"align"=>"C","onchange"=>"setVewData(this)"})
    form.setparams("machine_nm",{"title"=>self.human_attribute_name(:machine_nm),"type"=>"textJ",'style'=>"width:50px;","maxlength"=>"10","inputFlg"=>1,"essFlg"=>0,"align"=>"L","onchange"=>"setVewData(this)"})
    WokerNumKey.each{|key| form.setparams(key,{"title"=>self.human_attribute_name(key),"type"=>"textN",'style'=>"width:16px;","maxlength"=>"2","inputFlg"=>1,"essFlg"=>0,"align"=>"R","onchange"=>"calcCount(this)"})}
    form.setparams("io_flg",{"title"=>self.human_attribute_name(:io_flg),"type"=>"hidden",'size'=>"1","maxlength"=>"1","inputFlg"=>1,"essFlg"=>0,"align"=>"C",
      "list"=>CargoRequest::IOFlg,"onchange"=>"setData(this)"})
    form.setparams("quantity",{"title"=>self.human_attribute_name(:quantity),"type"=>"textJ",'size'=>"40","maxlength"=>"64","inputFlg"=>1,"essFlg"=>0,"align"=>"L","onchange"=>"setData(this)"})
    form.setparams("note",{"title"=>self.human_attribute_name(:note),"type"=>"textJ",'size'=>"40","maxlength"=>"128","inputFlg"=>1,"essFlg"=>0,"align"=>"L","onchange"=>"setData(this)"})
    form.setparams("dirt_flg",{"title"=>self.human_attribute_name(:dirt_flg),"type"=>"hidden",'size'=>"1","maxlength"=>"1","inputFlg"=>1,"essFlg"=>0,"align"=>"C","label"=>"汚れ有り","onclick"=>"setData(this)"})
    form.setparams("matter1",{"title"=>self.human_attribute_name(:matter1),"type"=>"textJ",'size'=>"40","maxlength"=>"128","inputFlg"=>1,"essFlg"=>0,"align"=>"L","onchange"=>"setData(this)"})
    form.setparams("matter2",{"title"=>self.human_attribute_name(:matter2),"type"=>"textJ",'size'=>"40","maxlength"=>"128","inputFlg"=>1,"essFlg"=>0,"align"=>"L","onchange"=>"setData(this)"})
    form.setparams("momo_fm",{"title"=>self.human_attribute_name(:momo_fm),"type"=>"textJ",'size'=>"10","maxlength"=>"64","inputFlg"=>1,"essFlg"=>0,"align"=>"L","onchange"=>"setData(this)"})
    form.setparams("momo_dm",{"title"=>self.human_attribute_name(:momo_dm),"type"=>"textJ",'size'=>"15","maxlength"=>"64","inputFlg"=>1,"essFlg"=>0,"align"=>"L","onchange"=>"setData(this)"})
    form.setparams("momo_mc",{"title"=>self.human_attribute_name(:momo_mc),"type"=>"textJ",'size'=>"10","maxlength"=>"64","inputFlg"=>1,"essFlg"=>0,"align"=>"L","onchange"=>"setData(this)"})
    form.setparams("momo_wi",{"title"=>self.human_attribute_name(:momo_wi),"type"=>"textJ",'size'=>"18","maxlength"=>"64","inputFlg"=>1,"essFlg"=>0,"align"=>"L","onchange"=>"setData(this)"})
    form.setparams("momo_dr",{"title"=>self.human_attribute_name(:momo_dr),"type"=>"textJ",'size'=>"28","maxlength"=>"64","inputFlg"=>1,"essFlg"=>0,"align"=>"L","onchange"=>"setData(this)"})
    form.setparams("momo_wk",{"title"=>self.human_attribute_name(:momo_wk),"type"=>"textJ",'size'=>"48","maxlength"=>"64","inputFlg"=>1,"essFlg"=>0,"align"=>"L","onchange"=>"setData(this)"})
    %w[ob hh rk wk].each{|key|form.setparams("#{key}_np",{"title"=>self.human_attribute_name("#{key}_np"),"type"=>"hidden",'size'=>"3","maxlength"=>"2","inputFlg"=>1,"essFlg"=>0,"align"=>"R"})}
    return form
  end

  #
  #===本船作業依頼を反映＆配番開始 Copy request and start numbering
  def self.copy_request(t_date)
    cp_key = [:work_class,:serial_no,:move_no,:work_name,:work_cd,:cargo_name,:work_place,:i_time,:s_time,:e_time,:machine_nm,:io_flg,:quantity,:note,:dirt_flg,:matter1,:matter2,:updated_at,:updated_uid]
    work_no = 0; desp_index = 1;
    #本船作業 Onboard work
    pre_data={:move_no=>nil,:work_place=>nil}
    data_tbl = CargoRequest.includes(:cargo).where(:work_date=>t_date,:work_class=>1).order(:work_place=>:asc,:move_no=>:asc,:work_no=>:asc,:serial_no=>:asc)
    data_tbl.each{|request|
      if request[:move_no]!=pre_data[:move_no] || request[:work_place]!=pre_data[:work_place]
        work_no+=1
        pre_data[:move_no] = request[:move_no]
        pre_data[:work_place] = request[:work_place]
      end
      if request.cargo.blank?
        cargo = self.new({
          :cargo_request_id => request[:id],
          :work_date => t_date,
          :work_no => work_no,
          :desp_index => desp_index,
          :created_at => request[:created_at],
          :created_uid => request[:created_uid],
        })
        cp_key.each{|key|cargo[key]=request[key]}
        WokerNumKey.each{|key|cargo[key]=request[key]}
        cargo[:wk_w]=request[:wk_w]
        cargo.save!
      elsif request[:updated_at] > request.cargo[:updated_at]
        request.cargo[:work_no]=work_no
        request.cargo[:desp_index]=desp_index
        cp_key.each{|key| request.cargo[key]=request[key]}
        WokerNumKey.each{|key| request.cargo[key]=request[key]}
        request.cargo[:wk_w]=request[:wk_w]
        request.cargo.save!
      end
      desp_index += 1
      request[:esta_flg] = 1
      request.save!
    }unless data_tbl.blank?
    #沿岸作業 coastal work
    pre_data={:move_no2=>nil,:work_place=>nil}
    sql = Arel.sql("CAST(SUBSTRING(move_no2,3) AS UNSIGNED) ASC, work_place ASC")
    # data_tbl = CargoRequest.includes(:cargo).where(:work_date=>t_date,:work_class=>2).order(:move_no2=>:asc,:work_place=>:asc)
    data_tbl = CargoRequest.includes(:cargo).where(:work_date=>t_date,:work_class=>2).order(sql)
    
    data_tbl.each{|request|
      if request[:move_no2]!=pre_data[:move_no2] || request[:work_place]!=pre_data[:work_place]
        work_no+=1
        pre_data[:move_no2] = request[:move_no2]
        pre_data[:work_place] = request[:work_place]
      end
      if request.cargo.blank?
        cargo = self.new({
          :cargo_request_id => request[:id],
          :work_date => t_date,
          :work_no => work_no,
          :desp_index => desp_index,
          :created_at => request[:created_at],
          :created_uid => request[:created_uid],
        })
        cp_key.each{|key| cargo[key]=request[(key == :move_no ? :move_no2 : key)]}
        WokerNumKey.each{|key|cargo[key]=request[key]}
        cargo.save!
      elsif request[:updated_at] > request.cargo[:updated_at]
        request.cargo[:work_no]=work_no
        request.cargo[:desp_index]=desp_index
        cp_key.each{|key| request.cargo[key]=request[(key == :move_no ? :move_no2 : key)]}
        WokerNumKey.each{|key|request.cargo[key]=request[key]}
        request.cargo.save!
      end
      desp_index += 1
      request[:esta_flg] = 1
      request.save!
    }unless data_tbl.blank?
    #お休み rest
    data_tbl = CargoRequest.includes(:cargo).where(:work_date=>t_date,:work_class=>9).order(:work_no=>:asc,:serial_no=>:asc)
    data_tbl.each{|request|
      if request[:serial_no] == 0
        work_no+=1
      end
      if request.cargo.blank?
        cargo = self.new({
          :cargo_request_id => request[:id],
          :work_date => t_date,
          :work_no => work_no,
          :desp_index => desp_index,
          :created_at => request[:created_at],
          :created_uid => request[:created_uid],
        })
        cp_key.each{|key|cargo[key]=request[key]}
        WokerNumKey.each{|key|cargo[key]=request[key]}
        cargo.save!
      elsif request[:updated_at] > request.cargo[:updated_at]
        request.cargo[:work_no]=work_no
        request.cargo[:desp_index]=desp_index
        cp_key.each{|key|request.cargo[key]=request[key]}
        WokerNumKey.each{|key|request.cargo[key]=request[key]}
        request.cargo.save!
      end
      desp_index += 1
      request[:esta_flg] = 1
      request.save!
    }unless data_tbl.blank?
  end
  #
  #=== 作業時間(開始-終了（機械用）)、超過時間を算出して保持  Calculate and maintain working time (start-end (for machines)) and excess time
  def calc_wk_time
    s_time = WorkTimeAggregate.mk_time(self[:work_date],self[:s_time],RegularSTime)
    e_time = WorkTimeAggregate.mk_time(self[:work_date],self[:e_time],RegularETime)
    e_time += 3600*24 if s_time > e_time
    self[:work_time] , self[:orver_time] = WorkTimeAggregate.calc_prescribed_work_time(self[:work_date],self[:s_time],self[:e_time])
  end
  #
  #=== 荷役成立を作業依頼に反映 Reflect completion of cargo handling in work request
  def cargo_request_status_link
    if self[:conf_flg]==1 && self[:cargo_request_id]!=0
      unless self.cargo_request[:esta_flg] == self[:esta_flg]
        self.cargo_request[:esta_flg] = self[:esta_flg]
        self.cargo_request[:updated_uid] = self[:updated_uid]
        self.cargo_request.save
      end
    end
  end

  #
  #=== 配番用割当データリストを返す Return the allocation data list for numbering
  def get_assignment_list
    assignment_list = {}
    WkType.each{|text,wk_type| 
      assignment_list[wk_type] = {:worker=>{},:machine=>{},:note=>[]} }
    self.cargo_worker.each{|data|
      assignment_list[data[:wk_type]][:worker][data[:wk_index]] = {
        :user_id=>data[:user_id],
        :login_id=>data[:login_id],
        :work_class=>data[:work_class],
        :work_index=>data[:work_index],
        :bus_flg=>data[:bus_flg],
        :wk_class=>data[:wk_class],
        :competence=>data[:competence],
        :s_time=>data[:s_time].try(:strftime,"%H:%M"),
        :e_time=>data[:e_time].try(:strftime,"%H:%M"),
        :work_time=>data[:work_time],
        :orver_time=>data[:orver_time],
        :lock_flg=>data[:lock_flg],
      }
    }
    self.cargo_machine.each{|data|
      assignment_list[data[:wk_type]][:machine][data[:wk_index]] = {
        :machine_id=>data[:machine_id],
        :machine_cd=>data[:machine_cd],
        :m_type=>data[:m_type],
        :work_time=>data[:work_time],
        :work_index=>data[:work_index],
        :lock_flg=>data[:lock_flg],
      }
    }
    return assignment_list
  end

  # 人数カラムの更新(*_np Update the number of people column (*_np
  def update_np_count
    cargo_id = self[:id]
    cargo_wokers = CargoWorker.where(:cargo_id=>cargo_id)
    return if cargo_wokers.blank?
    # 0初期化  0 initialization
    count_fields = [:ob_np,:hh_np,:wk_np]
    count_fields.each {|key| self[key]=0}
    
    cargo_wokers.each do |cw|
      next if cw[:wk_type]!="wk"
      login_id = cw[:login_id].upcase
      self[:hh_np]+=1 if login_id.include?("HITACH")
      self[:ob_np]+=1 if login_id.include?("OB")
      self[:wk_np]+=1 unless login_id.include?("ROKYO")
    end

    # 変更があればsave Save any changes
    self.save if self.changes.any?{|key,(bef,aft)| bef!=aft}

  end

  def get_wk_w()
    wk_w = 0
    sum_up_key = [:hd_w,:db_w,:hs_w,:sn_w,:eg_w,:ot_w]
    sum_up_key.each do |key|
        wk_w += self[key].to_i
    end
    wk_w
  end

  #
  #=== 配番データ登録 Number allocation data registration
  def self.update_assignment(login_id,work_date,conf_flg,cargo,worker,machine)
    #従事データを一旦論理削除 Logically delete engagement data once
    cargo_data = self.find_by({:id=>cargo[:id],:work_date=>work_date})
    # cargo_data = self.find_by({:id=>cargo[:id],:load_lists=>work_date})
    raise NotFoundError.new("cargo_data cargo.id=[#{cargo[:id]}] and work_date=[#{work_date.try(:strftime,"%Y/%m/%d")}] is NotFound") if cargo_data.nil?
    CargoWorker.delete_all(login_id,["cargo_id=? ",cargo_data[:id]])
    CargoMachine.delete_all(login_id,["cargo_id=? ",cargo_data[:id]])
    #作業予定を更新 Update work schedule
    cargo.each{|key,val|
      case key
      when "id" #スキップ skip
      else ; cargo_data[key] = (val.blank? ? nil : val)
      end
    }
    cargo_data[:conf_flg] = (conf_flg.blank? ? 0 : 1)
    cargo_data.save! if cargo_data.changed?
    #荷役従事者を更新 Update cargo handling personnel
    worker.each{|key,val|
      if key =~ /^(\w+)_(\d+)_login_id$/ && val.present?
        wk_type = $1
        wk_index = $2
        datas = {:cargo_id=>cargo_data[:id],:work_date=>work_date,:wk_type => wk_type,:wk_index => wk_index,
                 :user_id=>worker["#{wk_type}_#{wk_index}_user_id"],
                 :login_id=>worker["#{wk_type}_#{wk_index}_login_id"],
                 :work_index=>worker["#{wk_type}_#{wk_index}_work_index"],
                 :bus_flg=>worker["#{wk_type}_#{wk_index}_bus_flg"],
                 :work_class=>worker["#{wk_type}_#{wk_index}_work_class"],
                 :wk_class=>worker["#{wk_type}_#{wk_index}_wk_class"],
                 :competence=>worker["#{wk_type}_#{wk_index}_competence"],
                 :s_time=>worker["#{wk_type}_#{wk_index}_s_time"],
                 :e_time=>worker["#{wk_type}_#{wk_index}_e_time"],
                 :work_time=>worker["#{wk_type}_#{wk_index}_work_time"],
                :orver_time=>worker["#{wk_type}_#{wk_index}_orver_time"],
                :lock_flg=>worker["#{wk_type}_#{wk_index}_lock_flg"],
        }
        CargoWorker.create_data([:cargo_id,:wk_type,:wk_index],datas,login_id,false,true)
      end
    }unless worker.blank?
    #荷役従事機械 Update cargo handling personnel
    machine.each{|key,val|
      if key =~ /^(\w+)_(\d+)_machine_id$/ && val.present?
        wk_type = $1
        wk_index = $2
        datas = {:cargo_id=>cargo_data[:id],:work_date=>work_date,:machine_id=>val,:wk_type => wk_type,:wk_index => wk_index,
            :machine_cd=>machine["#{wk_type}_#{wk_index}_machine_cd"],
            :m_type=>machine["#{wk_type}_#{wk_index}_m_type"],
            :work_time=>machine["#{wk_type}_#{wk_index}_work_time"],
            :work_index=>machine["#{wk_type}_#{wk_index}_work_index"],
            :lock_flg=>machine["#{wk_type}_#{wk_index}_lock_flg"],
            }
        CargoMachine.create_data([:cargo_id,:wk_type,:wk_index],datas,login_id,true,true)
      end
    }unless machine.blank?
  end
  #
  #=== 自動配番他 Automatic numbering etc.
  def self.mk_assignment(queue,work_date,mord)
    extend MkAssignment
    case mord
    when "copyFM" ; copy_fm(queue,work_date)
    when "copyDM" ; copy_dm(queue,work_date)
    when "mkAssignment" ; auto_assignment(queue,work_date)
    end
  end

  #
  #=== 作業時間を再計算 Recalculate working time
  def recalculate_work_time(user_login_id)
    cargo_i_time = self[:i_time]
    cargo_s_time = self[:s_time]
    cargo_e_time = self[:e_time]

    cws = self.cargo_worker
    return if cws.blank?
    cws.each do |cw|
      # UAT-305: lock_flgが1の場合は再計算しない UAT-305: Do not recalculate if lock_flg is 1
      next if cw[:lock_flg]==1
      next if cw[:s_time]==cargo_i_time && cw[:e_time]==cargo_e_time
      
      if cargo_i_time.blank? || cargo_e_time.blank?
        cw[:s_time] = cargo_i_time
        cw[:e_time] = cargo_e_time
        cw[:work_time] = 0
        cw[:orver_time] = 0
        cw[:updated_at]  = Time.now
        cw[:updated_uid] = user_login_id
        cw.save
        next
      end

      s_time = cargo_i_time
      e_time = cargo_e_time
      if cw[:bus_flg]==1
        adj_s_time,adj_e_time = WorkTimeAggregate.adjust_stime_etime_by_bus_flags(s_time,e_time,cargo_i_time,cw[:bus_flg])
        s_time = adj_s_time
        e_time = adj_e_time
      end
      work_time,orver_time = WorkTimeAggregate.calc_legal_work_time(self[:work_date],s_time,e_time,cw[:bus_flg])
      cw[:s_time]      = s_time
      cw[:e_time]      = e_time
      cw[:work_time]   = work_time
      cw[:orver_time]  = orver_time
      cw[:updated_at]  = Time.now
      cw[:updated_uid] = user_login_id
      cw.save
    end
  end


  #
  #=== 指定日に指定ユーザが割当されている配番リストを返す Returns the numbered list to which the specified user is assigned on the specified date
  def self.get_assignment_cargo(t_date:,user_id:nil,login_id:nil)
    cargos = Cargo.where(:work_date=>t_date)
    ids = []
    cargos.each do |cargo|
      cw = CargoWorker.where(:cargo_id=>cargo.id).where(:login_id=>login_id) if login_id
      cw = CargoWorker.where(:cargo_id=>cargo.id).where(:user_id=>user_id) if user_id
      ids << cargo.id if cw.present?
    end
    cargos = Cargo.where(id:ids)
    return cargos
  end
  #
  #=== 作業カテゴリ名を返す Return work category name
  # 例）"fm"→"FM"、"dr"→"取扱者" Example) "fm" → "FM", "dr" → "handler"
  def self.wk_type_str(key)
    wk_type_pair = WkType.find { |ary| key == ary[1] }
    wk_type_pair ? wk_type_pair[0] : nil
  end
  #
  #=== 配番画面設定 Numbering screen settings
  def self.tbl_setting
    return { :no => {:title=>"No",:w_size=>2,:align=>"R"},
             :work_name => {:w_size=>8},
             :cargo_name => {:w_size=>8},
             :work_place => {:title=>"場所",:w_size=>4},
             :s_time => {:title=>"時間",:w_size=>4,:align=>"C"},
             :fm => {:title=>"責任",:col=>1},
             :dm => {:title=>"D/M",:col=>2},
             :mc => {:title=>"機械",:col=>1,:align=>"C"},
             :wi => {:title=>"ｳｨﾝﾁ取扱者",:col=>2},
             :dr => {:title=>"取扱者",:col=>4},
             :wk => {:title=>"船内／沿岸",:col=>5},
             :np => {:title=>"臨時",:w_size=>7,:align=>"R"},
             :wk_np => {:title=>"人",:w_size=>2,:align=>"R"},
             :i_time => {:title=>"出勤",:w_size=>4,:align=>"C"},
             :note => {:w_size=>16},
             :r_block => [:no, :work_name, :cargo_name,:work_place],
             :m_block => [:s_time, :fm, :dm, :mc, :wi, :dr, :wk],
             :l_block => [:np, :wk_np, :i_time, :note],
             }
  end
end
