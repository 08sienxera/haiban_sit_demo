class ResultCargo < ApplicationRecord
  extend Common::Func
  include CargoEditUser
  belongs_to  :cargo_request , :optional => true
  has_many :result_cargo_worker
  has_many :result_cargo_machine
  default_scope {where(:deleted_at => nil)}

  #設定なし時の値 Value without setting
  BLANK = nil

  #
  #=== 配番データのコピー Copy numbering data
  def self.copy_cargo(queue,work_date_ymd,uid)
    extend MkAssignment
    do_copy_cargo(queue,work_date_ymd,uid)
  end

  #
  #=== 配番用割当データリスト Assignment data list for numbering
  def get_assignment_list
    assignment_list = {}
    Cargo::WkType.each{|text,wk_type| 
      assignment_list[wk_type] = {:worker=>{},:machine=>{},:note=>[]} }
    self.result_cargo_worker.each{|data|
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
        :base_no=>data[:base_no],
      }
    }
    self.result_cargo_machine.each{|data|
      assignment_list[data[:wk_type]][:machine][data[:wk_index]] = {
        :machine_id=>data[:machine_id],
        :machine_cd=>data[:machine_cd],
        :m_type=>data[:m_type],
        :work_time=>data[:work_time],
        :maintenanc_type=>data[:maintenanc_type],
        :e_date=>data[:e_date].try(:strftime,"%Y/%m/%d"),
        :note=>data[:note],
        :work_index=>data[:work_index],
      }
    }
    return assignment_list
  end

  # 人数カラムの更新(*_np | Update the number of people column (*_np
  def update_np_count
    result_cargo_id = self[:id]
    result_cargo_wokers = ResultCargoWorker.where(:result_cargo_id=>result_cargo_id)
    return if result_cargo_wokers.blank?
    # 0初期化  0 initialization
    count_fields = [:ob_np,:hh_np,:wk_np]
    count_fields.each {|key| self[key]=0}
    
    result_cargo_wokers.each do |rcw|
      next if rcw[:wk_type]!="wk"
      login_id = rcw[:login_id].upcase
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
  #=== 実績データ登録 Record data registration
  def self.update_assignment(login_id,work_date,conf_flg,cargo,worker,machine)
    #従事データを一旦論理削除 Logically delete engagement data once
    cargo_data = self.find_by({:id=>cargo[:id],:work_date=>work_date})
    raise NotFoundError.new("cargo.id=[#{cargo[:id]}] and work_date=[#{work_date.try(:strftime,"%Y/%m/%d")}]") if cargo_data.nil?
    ResultCargoWorker.delete_all(login_id,["result_cargo_id=? ",cargo_data[:id]])
    ResultCargoMachine.delete_all(login_id,["result_cargo_id=? ",cargo_data[:id]])
    #作業実績を更新 Update work history
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
        datas = {:result_cargo_id=>cargo_data[:id],:work_date=>work_date,:wk_type => wk_type,:wk_index => wk_index,
                 :user_id=>worker["#{wk_type}_#{wk_index}_user_id"],
                 :login_id=>worker["#{wk_type}_#{wk_index}_login_id"],
                 :work_class=>worker["#{wk_type}_#{wk_index}_work_class"],
                 :wk_class=>worker["#{wk_type}_#{wk_index}_wk_class"],
                 :s_time=>worker["#{wk_type}_#{wk_index}_s_time"],
                 :e_time=>worker["#{wk_type}_#{wk_index}_e_time"],
                 :work_time=>worker["#{wk_type}_#{wk_index}_work_time"],
                 :orver_time=>worker["#{wk_type}_#{wk_index}_orver_time"],
                 :base_no=>worker["#{wk_type}_#{wk_index}_base_no"],
                 :work_index=>worker["#{wk_type}_#{wk_index}_work_index"],
                 :bus_flg=>worker["#{wk_type}_#{wk_index}_bus_flg"],
        }
        rc_worke = ResultCargoWorker.create_data([:result_cargo_id,:wk_type,:wk_index],datas,login_id,false,true)
        rc_worke.delay.update_vacation if cargo_data[:conf_flg] == 1
      end
    }unless worker.blank?
    #荷役従事機械 Cargo handling machinery
    machine.each{|key,val|
      if key =~ /^(\w+)_(\d+)_machine_id$/ && val.present?
        wk_type = $1
        wk_index = $2
        datas = {:result_cargo_id=>cargo_data[:id],:work_date=>work_date,:machine_id=>val,:wk_type => wk_type,:wk_index => wk_index,
            :machine_cd=>machine["#{wk_type}_#{wk_index}_machine_cd"],
            :m_type=>machine["#{wk_type}_#{wk_index}_m_type"],
            :work_time=>machine["#{wk_type}_#{wk_index}_work_time"],
            :work_index=>machine["#{wk_type}_#{wk_index}_work_index"],
            :maintenanc_type=>machine["#{wk_type}_#{wk_index}_maintenanc_type"],
            :e_date=>machine["#{wk_type}_#{wk_index}_e_date"],
            :note=>machine["#{wk_type}_#{wk_index}_note"],
            }
        rc_machine = ResultCargoMachine.create_data([:result_cargo_id,:wk_type,:wk_index],datas,login_id,false,true)
        rc_machine.delay.update_maintenance if cargo_data[:conf_flg] == 1 && rc_machine[:maintenanc_type].present?
      end
    }unless machine.blank?
  end

  #=== 実績CSV用配列データ作成 Create array data for actual CSV
  def self.get_csv_data(t_date)
    #荷役実績(既存連携データ) Cargo handling record (existing linked data)
    require 'csv'
    work_date = t_date
    header = %w(作業日付 作業区分 動静番号 沿岸作業コード 連番 区分 従業員番号 氏名 機械コード 荷役機械名 機械の区分 免税軽油該当 作業内での連番 作業順 作業内容)
    work_type = {"fm"=>0,"dm"=>1,"wi"=>3,"dr"=>4,"wk"=>5}
    output = []; work_list = {}; machine_list = {};
    output << CSV.generate_line(header)

    result_cargos = ResultCargo.includes([result_cargo_worker: :user,result_cargo_machine: :machine]).where(work_date:work_date,conf_flg:1)
    result_cargos.each do |cargo|
      result_cargo_workers = cargo.result_cargo_worker.where("user_id<>0")
      result_cargo_machines = cargo.result_cargo_machine
      work_index  = -1 #  作業内での連番:同一作業依頼内での連番 0開始のため-1で初期化 Sequential number within the work: Sequential number within the same work request. Initialize with -1 to start with 0.
      result_cargo_workers.each do |worker|
        next if worker.user.blank?
        work_list[worker.login_id] = [] unless work_list[worker.login_id]
        work_list[worker.login_id] << worker
        tmpline = []
        tmpline << work_date
        tmpline << cargo.work_class
        tmpline << (cargo.work_class == 1 ? cargo.move_no : BLANK)
        tmpline << (cargo.work_class == 2 ? cargo.move_no : BLANK)
        tmpline << cargo.serial_no
        tmpline << 1
        tmpline << worker.login_id
        tmpline << worker.user.name
        tmpline << BLANK
        tmpline << BLANK
        tmpline << BLANK
        tmpline << BLANK
        tmpline << work_index +=1
        tmpline << (work_list[worker.login_id].count)-1
        tmpline << work_type[worker.wk_type] || BLANK
        
        output << CSV.generate_line(tmpline)
      end
      work_index  = -1 #  作業内での連番:同一作業依頼内での連番 0開始のため-1で初期化 Sequential number within the work: Sequential number within the same work request. Initialize with -1 to start with 0.
      result_cargo_machines.each do |machine|
        next if machine.machine.blank?
        machine_list[machine.machine_cd] = [] unless machine_list[machine.machine_cd]
        machine_list[machine.machine_cd] << machine
        tmpline = []
        tmpline << work_date
        tmpline << cargo.work_class
        tmpline << (cargo.work_class == 1 ? cargo.move_no : BLANK)
        tmpline << (cargo.work_class == 2 ? cargo.move_no : BLANK)
        tmpline << cargo.serial_no
        tmpline << 2
        tmpline << BLANK
        tmpline << BLANK
        tmpline << machine.machine_cd
        tmpline << machine.machine.name
        tmpline << ((machine.machine.a_category == "N" || machine.machine.a_category.blank?) ? BLANK : machine.machine.a_category)
        tmpline << machine.machine.light_oil
        tmpline << work_index +=1
        tmpline << (machine_list[machine.machine_cd].count)-1
        tmpline << work_type[machine.wk_type] || BLANK

        output << CSV.generate_line(tmpline)
      end
    end
    return output
  end

  
  #=== 実績用 荷役、荷役作業員、荷役機械のデータを返す For actual results: Returns data on cargo handling, cargo handling workers, and cargo handling machines.
  def self.get_daily_work_data(t_date)
    work_data = ResultCargo.get_work_data(t_date)
    work_cds = work_data.pluck(:work_cd).uniq
    work_cd_hash = CargoCdMaster.where(:work_cd=>work_cds).pluck(:work_cd,:cargo_class).to_h
    cargo_classes = work_cd_hash.values.uniq
    cargo_class_hash = CargoClassMaster.where(:cargo_class=>cargo_classes).pluck(:cargo_class,:name_s).to_h

    work_data = work_data.group_by(&:work_date)
    machine_category_map = {
      "A"=>:sum_tl,"C"=>:sum_cr,
      "D"=>:sum_bl,"F"=>:sum_lf,
      "S"=>:sum_sc
    }

    def_agg_data = {
      :work_date=>nil,:move_no=>"",:name=>"",
      :type=>"港湾運送",:clazz=>"",:sum_wk=>0,:sum_temp=>0,
      :sum_tl=>0,:sum_cr=>0,:sum_bl=>0,
      :sum_lf=>0,:sum_sc=>0,:sum_mcs=>0
    }

    day_data = work_data.transform_values do |result_cargos|
      result_cargos.map do |rc|
        mcn_total = 0
        cargo_class = work_cd_hash[rc[:work_cd]]
        cargo_name = cargo_class_hash[cargo_class]

        data = def_agg_data.dup
        data[:work_date] = rc[:work_date].strftime("%y.%m.%d")
        data[:move_no] = rc[:move_no]
        data[:name] = rc[:work_name]
        data[:clazz] = "#{cargo_class} #{cargo_name}"
        if cws = rc.result_cargo_worker.to_a
          data[:sum_wk] = cws.length
          data[:temp_wk] = cws.filter{|cw| cw[:user_id]==0}.count
        end
        if cms = rc.result_cargo_machine.to_a
          cms.each do |cm|
            if a_category = machine_category_map[cm.machine[:a_category]]
              data[a_category] +=1 
              data[:sum_mcs] +=1
            end
          end
        end
        data
      end
    end
    total_data = day_data.transform_values do |aggs|
      aggs.each_with_object(
        {:sum_wk=>0,:temp_wk=>0,:sum_tl=>0,:sum_cr=>0,:sum_bl=>0,:sum_lf=>0,:sum_sc=>0,:sum_mcs=>0}
      ) do |agg_data,ret_data|
        ret_data.keys.each do |key|
          ret_data[key] += agg_data[key] 
        end
      end
    end
    return {day:day_data,total:total_data}
  end


  #=== 荷役作業実績表用の集計データを返す Returns aggregated data for cargo handling performance table
  def self.get_monthly_work_data(t_date)
    data_init = {
      :type=>"港湾運送",:clazz=>nil,
      :sum_wk=>0,:per_wk=>0.0,
      :sum_temp=>0,:per_temp=>0.0,
      :sum_tl=>0,:per_tl=>0.0,
      :sum_cr=>0,:per_cr=>0.0,
      :sum_bl=>0,:per_bl=>0.0,
      :sum_lf=>0,:per_lf=>0.0,
      :sum_sc=>0,:per_sc=>0.0,
      :sum_mcs=>0,:per_mcs=>0.0,
    }
    mapping = {
      :sum_wk=>:per_wk,
      :sum_temp=>:per_temp,
      :sum_tl=>:per_tl,
      :sum_cr=>:per_cr,
      :sum_bl=>:per_bl,
      :sum_lf=>:per_lf,
      :sum_sc=>:per_sc,
      :sum_mcs=>:per_mcs,
    }

    daily_data = ResultCargo.get_daily_work_data(t_date)
    total_data = data_init.dup.merge({:per_wk=>1.0,:per_temp=>1.0,:per_tl=>1.0,:per_cr=>1.0,:per_bl=>1.0,:per_lf=>1.0,:per_sc=>1.0,:per_mcs=>1.0})
    monthly_data = {}
    daily_data[:day].each do |work_date,aggs|
      aggs.each do |agg_data|
        clazz = agg_data[:clazz]
        ret_hash =  (monthly_data[clazz] ||= data_init.dup)
        ret_hash[:clazz] ||= clazz
        [:sum_wk,:sum_temp,:sum_tl,:sum_cr,:sum_bl,:sum_lf,:sum_sc,:sum_mcs].each do |key|
          value = agg_data[key]
          ret_hash[key] += value
          total_data[key] += value
        end
      end
    end

    mapping.keys.each{|key| mapping.delete(key) if total_data[key]==0}
    sum_keys = mapping.keys
    monthly_data.each do |_,agg_data|
      sum_keys.each.with_index do |sum_key,index|
        per_key = mapping[sum_key]
        sum_val = agg_data[sum_key]
        next if sum_val == 0
        agg_data[per_key] = (1.0 * agg_data[sum_key] / total_data[sum_key]).round(3)
      end
    end
    return {monthly:monthly_data,total:total_data}
  end

  #=== 荷役作業明細表用の集計データを返す Return summary data for material handling schedule
  def self.get_cargo_work_detail_data(s_date:,e_date:)
    r_cargos = ResultCargo.includes(:result_cargo_worker=>:woker,:result_cargo_machine=>:machine).where(:work_date=>(s_date..e_date)).order(:work_date=>:asc,:desp_index=>:asc)
    branch_name_hash = Branche.all.pluck(:cd,:name).to_h
    matrix = []
    user_cds = []
    matrix << %w(日付	作業区分	動静番号	本船名・作業名	揚積	貨物コード	貨物名	場所	出勤時刻	開始時刻	終了時刻	汚れ	作業員	従業員No 所属	作業	機械)
    r_cargos.each do |cargo|
      wokers = Woker.get_latest(cargo[:work_date]).where(:login_id=>cargo.result_cargo_worker.pluck(:login_id)).index_by(&:login_id)
      row = []
      row << cargo[:work_date].strftime("%Y/%m/%d")
      row << list_to_str(CargoRequest::WorkClasses,cargo[:work_class].to_s)
      # row << CargoRequest::WorkClasses[cargo[:work_class].to_i][0]
      row << cargo[:move_no]
      row << cargo[:work_name]
      row << CargoRequest::IOFlg[cargo[:io_flg].to_i][0]
      row << cargo[:work_cd]
      row << cargo[:cargo_name]
      row << cargo[:work_place]
      row << cargo[:i_time]&.strftime("%H:%M")
      row << cargo[:s_time]&.strftime("%H:%M")
      row << cargo[:e_time]&.strftime("%H:%M")
      row << CargoRequest::DirtFlg[cargo[:dirt_flg]||0][0]
      cargo_workers = cargo.result_cargo_worker
      next unless cargo_workers
      cargo_workers.each do |cw|
        woker = wokers[cw[:login_id]]
        next if woker.blank?
        c_row = row.dup
        c_row << cw.login_id
        c_row << "none"
        c_row << branch_name_hash[woker.branch_cd]
        c_row << CargoRequest::WkClasses[cw.wk_class]
        result_cargo_machines = cargo.result_cargo_machine.map do |rcm|
          m_hash = {
            cd: rcm.machine_cd,
            name: rcm.machine.name,
            wk_type: rcm.wk_type,
            wk_index: rcm.wk_index
          }
          m_hash
        end
        found_machine = result_cargo_machines.find{|rcm| rcm[:wk_type]==cw.wk_type && rcm[:wk_index]==cw.wk_index}
        machine_nm = found_machine ? found_machine[:name] : ""
        c_row << machine_nm
        user_cds << cw.login_id
        matrix << c_row
      end
    end
    
    user_name_hash = User.where(:login_id=>user_cds.uniq).pluck(:login_id,:name).to_h
    matrix.each do |row|
      user_cd = row[12]
      row[13] = user_name_hash[user_cd]
      row.map!{|v| v==nil ? "" : v}
    end
    matrix
  end

  #=== 作業員毎作業一覧用の集計データを返す Returns aggregated data for each worker's work list
  def self.get_woker_work_summary_data(s_date:,e_date:)

    branche_members = {}
    member = Woker.get_menber_list(e_date).rows
    member.each {|row|
      branche_members[row[0]] ||= []
      branche_members[row[0]] << [row[1],row[4]]
    }

    result_cargo_workers = ResultCargoWorker.joins(:result_cargo).includes(:result_cargo, :woker).where(:work_date=>(s_date..e_date)).order(:s_time=>:asc).group_by do |rcw|
      key = "#{rcw[:login_id]}_#{rcw[:work_date].strftime("%Y%m%d")}"
      key
    end
    
    cargo_wokers = CargoWorker.joins(:cargo).includes(:cargo, :woker).where(:work_date=>(s_date..e_date)).order(:s_time=>:asc).group_by do |cw|
      key = "#{cw[:login_id]}_#{cw[:work_date].strftime("%Y%m%d")}"
      key
    end
    
    work_summary = {}
    cargo_ids = Set.new
    result_cargo_ids = Set.new

    member.map{|m| m[1]}.each do |login_id|
      (s_date..e_date).each do |day|
        day_str = day.strftime("%Y%m%d")
        rcws = result_cargo_workers["#{login_id}_#{day_str}"]
        if rcws.present?
          # ==
          result_cargo_ids += rcws.map(&:result_cargo_id)
          work_summary[login_id] ||= {}
          work_summary[login_id][day] = [rcws[0].class.name,rcws]
          # ==
        elsif rcws.blank? && day==Date.today
          cws = cargo_wokers["#{login_id}_#{day_str}"]
          if cws.present?
            # ==
            cargo_ids += cws.map(&:cargo_id)
            work_summary[login_id] ||= {}
            work_summary[login_id][day] = [cws[0].class.name,cws]
            # ==

          end
        else
        end
      end
    end


    vacation_name_hash = VacationType.all.pluck(:id,:time_sheet_name).to_h
    vacation_hash = Vacation.where(:login_id=>member.map{|m| m[1]},:vacation_day=>(s_date..e_date)).map{|vac| ["#{vac[:login_id]}_#{vac[:vacation_day].strftime("%Y%m%d")}",vacation_name_hash[vac[:vacation_type_id]]]}.to_h

    cargos = Cargo.where(:id=>cargo_ids).pluck(:id,:work_class,:work_place,:cargo_name,:work_name).map{|t| [t[0],[t[1],t[2],t[3],t[4]]]}.to_h
    result_cargos = ResultCargo.where(:id=>result_cargo_ids).pluck(:id,:work_class,:work_place,:cargo_name,:work_name).map{|t| [t[0],[t[1],t[2],t[3],t[4]]]}.to_h

    work_time_summary = WorkTimeSummary.where(:t_cd=>member.map{|ary| ary[1]},:work_date=>s_date..e_date).map{|wts|
      login_id,work_date,p_orver_time,p_early_time = wts.values_at(:t_cd,:work_date,:p_orver_time,:p_early_time)
      key = "#{login_id}_#{work_date.strftime("%Y%m%d")}"
      sum_orver_time = p_orver_time.to_i + p_early_time.to_i
      [key,sum_orver_time]
    }.to_h

    work_time_summary_hash = {}
    work_summary.keys.each do |login_id|
      work_summary[login_id].each do |day,wk|
        day_str = day.strftime("%Y%m%d")
        key = "#{login_id}_#{day_str}"
        orver_time = 0
        class_name,cargo_workers = wk
        work_time = work_time_summary[key]
        if work_time.present?
          orver_time = (work_time.to_f/60).round(1)
        else
          # -- 計算方法見直し Review of calculation method
          # UAT222
          if cargo_workers.present?
            s_time = cargo_workers.map{|cw| cw.s_time.present? ? WorkTimeAggregate.mk_time(cw.work_date,cw.s_time,cw.s_time) : nil}.compact.min
            e_time = cargo_workers.map{|cw| cw.e_time.present? ? WorkTimeAggregate.mk_time(cw.work_date,cw.e_time,cw.e_time) : nil}.compact.max
            e_time = WorkTimeAggregate.mk_time(day,"16:00","16:00") if e_time.blank?
            e_time += 3600*24 if s_time.present? && e_time.present? && s_time > e_time
            if s_time.present? && e_time.present?
              pWorkTime = WorkTimeAggregate.calc_prescribed_work_time(day,s_time,e_time)
              p_orver_time = pWorkTime[1..2].sum
              orver_time = (p_orver_time.to_f/60).round(1)
            end
          end
        end
        work_time_summary_hash[key] = orver_time
      end
    end

    rel_data = {:members=>branche_members, :result_cargos=>result_cargos, :cargos=>cargos, :wt_summary=>work_time_summary_hash, :vacation_summary=>vacation_hash}

    return [s_date,e_date],work_summary, rel_data

  end
  
  #=== 指定日の荷役実績、荷役作業員実績、荷役機械実績を返す Returns the cargo handling results, stevedoring worker results, and material handling machine results for the specified date.
  def self.get_work_data(t_date)
    return ResultCargo.includes(:result_cargo_worker,:result_cargo_machine=>:machine).where(:work_date=>t_date).order(:desp_index=>:asc)
  end

end
