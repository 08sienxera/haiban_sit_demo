# coding: utf-8
class Woker < ApplicationRecord
  extend Common::Func
  default_scope {where(:deleted_at => nil)}
  belongs_to :user, primary_key: :login_id, foreign_key: :login_id, :optional => true
  has_many :cargo_wokers, class_name: 'CargoWorker',  primary_key: :login_id, foreign_key: :login_id

  # 技量キーリスト # Skill Key List
  CompetenceKey = %w[ca fmm fmc fma fmp dm sn od cc em ep cr3 cr5 cr6 cr7 cru wwm crg scm scc tlm tlc lf lfl ldc ldm bhh bhs bld blh slm slc sw sp clr crp cre crs w3 s5 s7 wgd wal w6e wbg wsm wsc wc wcc wlg mt tl]
  # 技量値リスト # Skill Value List
  CompetenceValue = [["×従事しない","-1"],["初心者","1"],["中級者","2"],["上級者","3"],["熟練者","4"],["指導者","5"]]
  # 技量値リスト（省略形 # Skill Value List (Abbreviated)
  SCompetenceValue = [["不可","-1"],["低","1"],["可","2"],["並","3"],["良","4"],["優","5"]]
  # 表示作業予定切替時刻 # Display work schedule change time
  SwitchTime = [15,30] # [時,分] # [hours, minutes]
  # 作業員区分リスト # Worker Classification List
  WTypeList = [["","-1"],["ＦＭ", "1"], ["ＯＰ", "2"], ["作業", "3"],["整備工場","4"],["道具倉庫","5"]]
  # 
  # 除外作業員リスト　※一部の帳票で使用 # List of excluded workers *Used in some forms
  WithoutMembers = %w(8400229 9000143 9100237)   
  #===コールバック callback
  after_create :remake_board_targets
  after_update :remake_board_targets

  #
  #===入力画面フォームの生成 Generation of input screen form
  def self.set_input_form(key)
    form = Common::CommonClass.new(key)
    applicables = Applicable.get_applicable_list(2)
    branch_list = Branche.getdatalist({:key=>:cd,:text=>:name,:where=>{:applicable=>Applicable.get_applicable(1)},:order=>:desp_index})
    form.setparams("applicable",{"title"=>self.human_attribute_name(:applicable),"type"=>"select",'size'=>"10","maxlength"=>"8","inputFlg"=>1,"essFlg"=>1,"align"=>"L",
      "list"=>applicables,"format"=>"%Y/%m/%d"})
    form.setparams("login_id",{"title"=>self.human_attribute_name(:login_id),"type"=>"textJ",'size'=>"9","maxlength"=>"16","inputFlg"=>1,"essFlg"=>1,"align"=>"L"})
    form.setparams("s_name",{"title"=>self.human_attribute_name(:s_name),"type"=>"textJ",'size'=>"8","maxlength"=>"8","inputFlg"=>1,"essFlg"=>1,"align"=>"L"})
    form.setparams("w_type",{"title"=>self.human_attribute_name(:w_type),"type"=>"select",'size'=>"8","maxlength"=>"8","inputFlg"=>1,"essFlg"=>0,"align"=>"L","list"=>WTypeList})
    form.setparams("branch_cd",{"title"=>self.human_attribute_name(:branch_cd),"type"=>"select",'size'=>"9","maxlength"=>"8","inputFlg"=>1,"essFlg"=>1,"align"=>"L","list"=>branch_list})
    CompetenceKey.each{|key|
      form.setparams("competence_#{key}",{"title"=>self.human_attribute_name("competence_#{key}"),"type"=>"radio",'size'=>"2","maxlength"=>"2","inputFlg"=>1,"essFlg"=>1,"align"=>"C",
        "list"=>CompetenceValue,"list_row_num"=>6,"defVal"=>"-1"})
    }
    form.setparams("desp_index",{"title"=>self.human_attribute_name(:desp_index),"type"=>"textN",'size'=>"10","maxlength"=>"9","inputFlg"=>1,"essFlg"=>1,"align"=>"R"})
    return form
  end
  #
  #===更新画面フォームの生成 Generating an update screen form
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
  #===一覧画面フォームの生成 Generating a list screen form
  def self.set_list_form(key)
    form = self.set_input_form(key)
    %w[desp_index].each{|pkey| form.unsetparams(pkey)}
    CompetenceKey.each{|key|form.unsetparams("competence_#{key}")}
    form.set_all_param("inputFlg",0)
    form.set_all_param("essFlg",0)
    form.setparams('id',{'title'=>'ID','type'=>'hidden','size'=>'20','maxlength'=>'16','inputFlg'=>0,'essFlg'=>0,'align'=>'R','noserch'=>"1"})
    form.set_index('id',0)
    form.setparam('login_id','link',{:action=>:edit,:id=>'id'})
    #CompetenceKey.each{|key|form.setparam("competence_#{key}",'list',SCompetenceValue)}
    return form
  end
  #
  #===作業員用、所属データ取得 For worker use, affiliation data acquisition
  def self.get_user_branch(login_id,t_date=Date.today)
    ret = {}
    woker = self.find_by({:login_id=>login_id, :applicable=>Applicable.get_applicable(2,t_date)})
    unless woker.blank?
      [:s_name,:branch_cd].each{|key| ret[key] = woker[key]}
      unless ret[:branch_cd].blank?
        branche = Branche.find_by({:cd=>ret[:branch_cd], :applicable=>Applicable.get_applicable(2,t_date)})
        ret[:branch_name] = branche[:name] unless branche.blank?
      end
    end
    return ret
  end
  #
  #===その他共有メンバーリスト Other shared member list
  def self.get_menber_list(t_date=Date.today,branche_cd=nil,my_id=nil,without_deleted_user=true)
    where = "wokers.applicable = '#{Applicable.get_applicable(2,t_date)}'"
    if branche_cd.present?
      if branche_cd.is_a?(Array)
        where << " and wokers.branch_cd in ('#{branche_cd.join("','")}')"
      else
        where << " and wokers.branch_cd = '#{branche_cd}'"
      end
    else
      where << " and wokers.branch_cd in ('#{Branche::WorkerBranchCd.join("','")}')"
    end
    where << " and wokers.deleted_at IS NULL" if without_deleted_user
    where << " and users.deleted_at IS NULL" if without_deleted_user

    order = "#{(my_id.present? ? "case when wokers.login_id='#{my_id}' then 0 else 1 end asc," : "")} wokers.branch_cd asc,wokers.desp_index asc"
    wokers = self.connection.select_all("select wokers.branch_cd,wokers.login_id,wokers.s_name,users.id,users.name from wokers inner join users on wokers.login_id=users.login_id where #{where} order by #{order}")
    # wokers = self.connection.select_all("select wokers.branch_cd,wokers.login_id,wokers.s_name,users.id,users.name from wokers left join users on wokers.login_id=users.login_id where #{where} order by #{order}")
    return wokers
  end
  #
  #===配番グループ名の取得 Retrieving the assignment group name
  def branch_nm
    branche = Branche.find_by({:applicable=>Applicable.get_applicable(1,self[:applicable]),:cd=>self[:branch_cd]})
    return branche.try(:name)
  end
  #
  #===荷役予定(必要人数設定) など力量毎集計 Loading and unloading schedule (required number of personnel) and other calculations by skill level.
  #注意：t_date:WhCalendar Note: t_date:WhCalendar
  def self.sum_competence(t_date)
    ret = {"dr"=>0,"wk"=>0}
    Cargo::WokerNumKey.each{|key| ret[key[0..1]]=0 }
    ret["ot_w"]=0
    applicable= Applicable.get_applicable(2,t_date[:t_date])
    #早退（2）以外の申請者は除外 Applicants other than those requesting early departure (2) are excluded.
    vacations = Vacation.where(["vacation_day=? and base_no <> '2' ",t_date[:t_date]])
    if vacations.blank?
      where = ["applicable=?",applicable]
    else
      where = ["applicable=? and not login_id in (?)",applicable,vacations.map{|vacation| vacation[:login_id]}]
    end
    wokers = self.where(where)
    wokers.each{|woker|
      can_dr = false ; can_wk  = false;
      #FM
      if (woker[:competence_fmm].to_i + woker[:competence_fmc].to_i + woker[:competence_fma].to_i + woker[:competence_fmp].to_i) > 0
        ret["fm"] += 1 
        can_dr = true
      end
      #DM
      if (woker[:competence_dm].to_i + woker[:competence_sn].to_i) > 0
        ret["dm"] += 1 
        can_dr = true
      end
      #WM
      if woker[:competence_wwm].to_i > 0
        ret["wm"] += 1 
        can_dr = true
      end
      #cr:ｸﾚｰﾝ crane
      if (woker[:competence_cr3].to_i + woker[:competence_cr5].to_i + woker[:competence_cr6].to_i + woker[:competence_cr7].to_i + woker[:competence_cru].to_i + woker[:competence_crg].to_i + woker[:competence_crp].to_i + woker[:competence_cre].to_i + woker[:competence_crs].to_i) > 0
        ret["cr"] += 1 
        can_dr = true
      end
      #ld:ローダ loader
      if (woker[:competence_ldc].to_i + woker[:competence_ldm].to_i) > 0
        ret["ld"] += 1 
        can_dr = true
      end
      #bh:ﾊﾞｯｸﾎｰ Backhoe
      if (woker[:competence_bhh].to_i + woker[:competence_bhs].to_i) > 0
        ret["bh"] += 1 
        can_dr = true
      end
      #sl:船内ﾛ-ﾀﾞ Onboard loader
      if (woker[:competence_slm].to_i + woker[:competence_slc].to_i) > 0
        ret["sl"] += 1 
        can_dr = true
      end
      #bl:ブル(トーザー) Bull (tozer)
      if (woker[:competence_bld].to_i + woker[:competence_blh].to_i) > 0
        ret["bl"] += 1 
        can_dr = true
      end
      #lf:リフト lift
      if (woker[:competence_lf].to_i + woker[:competence_lfl].to_i) > 0
        ret["lf"] += 1 
        can_dr = true
      end
      #sc:(ｽﾄﾗﾄﾞﾙｷｬﾘｱ：実入コンテナ運ぶやつ) (Straddle carrier: a vehicle used to transport loaded containers)
      if (woker[:competence_scm].to_i + woker[:competence_scc].to_i) > 0
        ret["sc"] += 1 
        can_dr = true
      end
      #tl:(ﾄﾗﾝｽﾌｧｰｸﾚｰﾝ：空コンテナ運ぶやつ) (Transport crane: a vehicle that transports empty containers)
      if (woker[:competence_tlm].to_i + woker[:competence_tlc].to_i) > 0
        ret["tl"] += 1 
        can_dr = true
      end
      #ot:他 others
      if (woker[:competence_od].to_i + woker[:competence_cc].to_i + woker[:competence_em].to_i + woker[:competence_ep].to_i) > 0
        ret["ot"] += 1 
        can_dr = true
      end
      #hd:作業-ハン Work-Han
      if (woker[:competence_w3].to_i + woker[:competence_s5].to_i + woker[:competence_s7].to_i) > 0
        ret["hd"] += 1 
        can_wk = true
      end
      #db:作業-土場 Work site - lumberyard
      if woker[:competence_wgd].to_i > 0
        ret["db"] += 1 
        can_wk = true
      end
      #hs:作業-配車 Work - Vehicle dispatch
      if woker[:competence_wal].to_i > 0
        ret["hs"] += 1 
        can_wk = true
      end
      #sn:作業-船内 Work - Onboard
      if (woker[:competence_w6e].to_i + woker[:competence_wbg].to_i + woker[:competence_wsm].to_i + woker[:competence_wsc].to_i+ woker[:competence_wlg].to_i) > 0
        ret["sn"] += 1 
        can_wk = true
      end
      #eg:作業-沿岸 work-coastal
      if (woker[:competence_wc].to_i + woker[:competence_wcc].to_i) > 0
        ret["eg"] += 1 
        can_wk = true
      end
      #ot_w:作業-他 work-other
      if (woker[:competence_sw].to_i + woker[:competence_sp].to_i + woker[:competence_clr].to_i) > 0
        ret["ot_w"] += 1 
        can_wk = true
      end
      ret["dr"] += 1 if can_dr
      ret["wk"] += 1 if can_wk
    }unless wokers.blank?
    return ret
  end
  #
  #===配番用作業員リスト(グループ毎）Worker assignment list (by group)
  #注意：t_date:WhCalendar Note: t_date:WhCalendar
  def self.get_assignment_list(t_date,branches,month_info)
    assignment_list = {} ; names = {}
    #休暇データ取得 Get vacation data
    vacations = Vacation.get_assignment_list(t_date[:t_date])
    #当月残業時間集計 Monthly overtime calculation
    total_work_time = CargoWorker.total_work_times(t_date[:t_date],month_info[:length])
    #グループ毎に仕分け Sort by group
    branches.each_key{|cd| assignment_list[cd]=[]}
    data_tbl = self.includes([:user]).where({:applicable=>Applicable.get_applicable(2,t_date[:t_date])}).order(:desp_index)
    data_tbl.each{|woker|
      assignment_data = {}
        assignment_data[:woker_id] = woker[:id]
        [:login_id,:s_name,:branch_cd].each{|key| assignment_data[key] = woker[key]}
        CompetenceKey.each{|c_key| assignment_data["competence_#{c_key}"] = woker["competence_#{c_key}"]}
        if woker.user.present?
          assignment_data[:user_id] = woker.user[:id]
          assignment_data[:name] = woker.user[:name]
          assignment_data[:auth_flg] = woker.user[:auth_flg]
          assignment_data[:branch_cd] = woker.user[:branch_cd] if assignment_data[:branch_cd].blank? && woker.user[:branch_cd].present?
        else
          assignment_data[:user_id] = 0
        end
        if vacations.has_key?(woker[:login_id])
          assignment_data[:vacation] = vacations[woker[:login_id]]
        else
          assignment_data[:vacation] = nil
        end
        # :p_work_time=>0,:p_orver_time=>0,:work_time2=>0,:orver_time2=>0
        if total_work_time.has_key?(woker[:login_id])
          assignment_data[:total_ywork_time] = total_work_time[woker[:login_id]][:y_work_time]
          assignment_data[:total_yorver_time] = total_work_time[woker[:login_id]][:y_orver_time]
          assignment_data[:total_work_time] = total_work_time[woker[:login_id]][:work_time]
          assignment_data[:total_orver_time] = total_work_time[woker[:login_id]][:orver_time]
          assignment_data[:total_pwork_time] = total_work_time[woker[:login_id]][:p_work_time]
          assignment_data[:total_porver_time] = total_work_time[woker[:login_id]][:p_orver_time]
          assignment_data[:total_work_time2] = total_work_time[woker[:login_id]][:work_time2]
          assignment_data[:total_orver_time2] = total_work_time[woker[:login_id]][:orver_time2]

        else
          assignment_data[:total_ywork_time] = 0
          assignment_data[:total_yorver_time] = 0
          assignment_data[:total_work_time] = 0
          assignment_data[:total_orver_time] = 0
          assignment_data[:total_pwork_time] = 0
          assignment_data[:total_porver_time] = 0
          assignment_data[:total_work_time2] = 0
          assignment_data[:total_orver_time2] = 0

        end
        if assignment_list.has_key?("#{woker[:branch_cd]}")
          assignment_list["#{woker[:branch_cd]}"] <<  assignment_data
        end
        names[woker[:login_id]] = woker[:s_nmae]
      }
    return [assignment_list,names]
  end

  #=== 指定カレンダー日の指定ユーザ荷役情報を返す Returns cargo handling information for the specified user on the specified calendar date.
  def self.get_schedule(wh_calendar,login_id)
    user = User.find_by(:login_id=>login_id)
    t_date = wh_calendar.t_date
    schedule =  {status:"",work_date:t_date}
    
    
    # 配番作業員情報の有無 Availability of assigned worker information
    cargo_works = CargoWorker.joins(:cargo).where(:login_id=>login_id,:work_date=>t_date).order("cargos.i_time asc")
    if cargo_works.present?
      conf_flg = cargo_works[0].cargo.conf_flg.to_i
      if conf_flg==0
        schedule[:status] = "pending"
      else
        schedule[:status] = "assigned"
      end
    else
      schedule[:status] = "unassigned"
    end

    # 休暇の有無 Availability of vacation
    if schedule[:status]=="unassigned"
      vacation = Vacation.find_by(:login_id=>user.login_id,:vacation_day=>t_date)
      if vacation.present? && !vacation.works_on?
        schedule[:status] = "vacation"
      end
    end

    return schedule unless schedule[:status]=="assigned"

    # 追加情報の作成 Creating additional information
    cargo_info = {
      i_time:nil,
      work_name:[],
      cargo_name:[],
      place:[],
      work:[],
      message:[],
      memo:[]
    }

    fastest_stime = cargo_works.minimum(:s_time)
    cargo_info[:i_time] = fastest_stime.present? ? fastest_stime.strftime("%H:%M") : ""

    cargo_works.each do |work|
      cargo = work.cargo
      work_name,cargo_name,work_place = cargo.values_at(:work_name,:cargo_name,:work_place)
      cargo_info[:work_name] << work_name if work_name.present?
      cargo_info[:cargo_name] << cargo_name if cargo_name.present?
      cargo_info[:place] << work_place if work_place.present?
      
      # 担当配番機械の取得 Acquisition of assigned machine number
      cargo_wokers   = cargo.cargo_worker.where(wk_type:work.wk_type)  
      cargo_machines = cargo.cargo_machine.where(wk_type:work.wk_type)  


      wokers = [
        cargo_wokers.find_by_wk_index(work.wk_index-1),
        work,
        cargo_wokers.find_by_wk_index(work.wk_index+1)
      ]
      machines = [
        cargo_machines.find_by_wk_index(work.wk_index-1),
        cargo_machines.find_by_wk_index(work.wk_index),
        cargo_machines.find_by_wk_index(work.wk_index+1)
      ]
      my_machine = []
      my_machine << machines[1] if machines[1].present?
      if my_machine.size == 0
        my_machine << machines[0] if machines[0].present? && wokers[0].present?
      else
        my_machine << machines[2] if machines[2].present? && wokers[2].blank?
      end

      work_str = Cargo.wk_type_str(work.wk_type)
      machine_str = my_machine.map {|m| m.machine_cd}.join("、")
      work_str = work_str + "(" + machine_str + ")" if my_machine.present?

      cargo_info[:work] << work_str
      rc = ResultCargo.find_by(:cargo_id=>work[:cargo_id])
      messenger = rc.present? ? rc : work.cargo
      cargo_info[:memo] << messenger["momo_#{work[:wk_type]}"] if messenger["momo_#{work[:wk_type]}"].present?
    end

    msg = CargoMsg.find_by(work_date:t_date,login_id:login_id)
    cargo_info[:memo] -= [nil]
    cargo_info[:message] << msg.msg if msg.present?
    ret_schedule = schedule.merge(cargo_info)
    ret_schedule
  end

  #=== 掲示公開対象を再設定 Reconfigure the list of people whose posts are publicly displayed.
  def remake_board_targets()
    branch_cd = self.branch_cd
    rel_board_group_id = {
        "1"=>[2,3],
        "2"=>[2,4],
        "3"=>[5,6],
        "4"=>[5,7],
    }
    boards = Board.where(board_group_id:rel_board_group_id[branch_cd])
    boards.each {|board| board.delay.set_targets}
  end

  #=== 荷役実績(既存連携データ)を返す Return cargo handling records (existing linked data)
  def self.get_time_card_data(tdate_str) 
    #休暇表示マップ | vacation display map
    vnames = VacationType.all.pluck(:id,:time_sheet_name).to_h
    

    #wokerからorder(:branch_cd,desp_index)で取り出して Extract from waker using order(:branch_cd,desp_index)
    #userとcargo_worker、vacationの情報をマージして出力する。 Merges user, cargo_worker, and vacation information and outputs it.
    #cargo_workerに複数データある場合、出勤時間は早い方、cargoの順に作業No、作業名を出力する If there are multiple entries in cargo_worker, the work number and work name will be output in the order of earliest start time, followed by cargo.
    require 'csv'
    csv_lines = []; 
    work_date = Date.strptime(tdate_str,"%Y/%m/%d")
    branch_cd_name_hash = Branche.all.pluck(:cd,:name).to_h
    worker_branch_counts = {}; branch_cd_name_hash.keys.each {|cd| worker_branch_counts[cd]=0}
    wokers = Woker.get_latest(work_date).includes(user: :vacations).where(:branch_cd=>%w(1 2 3 4)).where.not(:login_id=>WithoutMembers).order(:branch_cd,:desp_index)
    cargo_worker_group = CargoWorker.left_joins(cargo: :cargo_request)
                        .where(work_date: work_date)
                        .order("cargos.s_time ASC, cargo_requests.work_no ASC")
                        .group_by{|cw| cw.login_id}
    
    wokers.each do |woker|
      cargo_workers = cargo_worker_group[woker.login_id] || []
      vacation = woker.user&.vacations&.find {|v|v.vacation_day == work_date}

      # == CSVレコード CSV record
      line = []
      line << tdate_str # 日付(YYYY/MM/DD) Date (YYYY/MM/DD)
      line << woker.login_id # 従業員番号 employee number
      line << (woker.user&.name || woker.s_name) # 氏名 full name
      line << woker.branch_cd # 所属No branch number
      line << branch_cd_name_hash[woker.branch_cd] # 所属名 branch name
      line << worker_branch_counts[woker.branch_cd] +=1 # 所属通番 branch serial number
      earliest_start_time = cargo_workers.map(&:s_time).reject(&:blank?).sort[0]&.strftime("%H:%M")
      line << earliest_start_time # 出勤時間 start time
      work_cd = self.get_output_cd_number(earliest_start_time,vacation,cargo_workers)
      line << work_cd
      line << (vacation.blank? ? nil : vnames[vacation.vacation_type_id])
      # line << ((vacation.blank? || work_cd==1) ? nil : vnames[vacation.vacation_type_id])

      # ---- 配番作業員情報 Assigned worker information -----------------------
      # 作業No1, 作業No2, 作業No3 Task No. 1, Task No. 2, Task No. 3
      # 作業名1, 作業名2, 作業名3 Task name 1, Task name 2, Task name 3
      3.times do |index|
        cw = cargo_workers[index]
        line << cw&.cargo&.work_no
        line << cw&.cargo&.work_name
      end
      line << (cargo_workers.any?{|cw| cw.cargo.present? && cw.cargo.dirt_flg==1} ? "汚れ" : nil) # 備考（汚れ） Remarks (stains)
      # ---- 配番作業員情報(ここまで) Assigned worker information (end of section) ---------------

      csv_lines << CSV.generate_line(line)

      
    end
    return csv_lines
  end

  def self.get_output_cd_number(s_time,vacation,cargo_workers)
    cd = nil
    return cd if vacation.blank? && cargo_workers.blank?

    categolize_1_base_nos = [2,3,31,32,33,34,41,42]
    type_1 = %w[
      06:30 07:00 07:30 08:00 08:30 09:00 09:30 10:00
      10:30 11:00 11:30 12:00 12:30 13:00 13:30 14:00
      14:30 15:00 15:30 16:00
    ]
    type_2 = ["20:00"]

    holiday_work_flg = false

    if vacation.present?
      base_no,at_work = vacation.values_at(:base_no,:at_work)

      if base_no==6 && at_work==1 && cargo_workers.present?
        holiday_work_flg = true
      elsif categolize_1_base_nos.include?(base_no)
        if cargo_workers.present?
          cd = 1 if type_1.include?(s_time)
          cd = 2 if type_2.include?(s_time)
        end
      else
        cd = base_no
      end
    end

    return cd if cd.present?
    
    cd = 1 if type_1.include?(s_time)
    cd = 2 if type_2.include?(s_time)
    cd += 2 if cd.present? && holiday_work_flg

    cd

  end

  def self.mk_wow_excel(new_file_name,t_date,t_tarm,t_branch_cd=nil)

    # t_date => 「対象日」
    # {t_date-2day}終了時点での累積時間外 ... a
    # {t_date-1day}当日の作業の予定時間外数 ... b
    # {t_date-1day}終了時点での予想累積時間外 ... c = a+b
    # {t_date}の配番先の予想時間外数 ... cargo_worker ... d
      # Batche::WorkTimeAggregate.mk_worker_sum(worker_sum_by_date,lin,1) => return {...}
    # {t_date}終了時点での予想累積時間外 ... e = c+d
    
    # t_date => "Target Date"
    # Cumulative overtime at the end of {t_date-2day} ... a
    # Number of planned overtime hours for work on {t_date-1day} ... b
    # Estimated cumulative overtime at the end of {t_date-1day} ... c = a+b
    # Estimated number of overtime hours for the assigned worker at {t_date} ... cargo_worker ... d
    # Batche::WorkTimeAggregate.mk_worker_sum(worker_sum_by_date,lin,1) => return {...}
    # Estimated cumulative overtime at the end of {t_date} ... e = c+d

    excel    = Excel::ExcelClass.new(new_file_name)
    workbook = excel.excel
    t_branch_cd ||= Branche.cargo_work_group.pluck(:cd)
    branches = Branche.where(:cd=>t_branch_cd)


    # 小数点付きの書式 Format with decimal point
    s_date = t_tarm[:length][:begin_date]
    e_date = t_date

    t_tarm_wt_aggs = WorkTimeSummary.where(:aggr_flg=>"W",:work_date=>s_date..e_date)
    t_tarm_wt_aggs_hash = {}
    t_tarm_wt_aggs.each do |agg|
      # binding.break if agg.t_cd == "001"
      t_tarm_wt_aggs_hash[agg.t_cd] ||= [0,0,0] # p_orver_time 前々日までの累計、前日、p_over_time Cumulative total up to two days prior, previous day,
      p_early_time = agg[:p_early_time]
      p_orver_time = agg[:p_orver_time]
      if agg[:work_date]==t_date-1
        t_tarm_wt_aggs_hash[agg.t_cd][1] += (p_early_time+p_orver_time) # UAT297により未使用 Unused by UAT297
      elsif agg[:work_date]<=t_date-2
        t_tarm_wt_aggs_hash[agg.t_cd][0] += (p_early_time+p_orver_time)
      end
    end

    cargo_wokers = CargoWorker.joins(:cargo).includes(:cargo).where(:work_date=>t_date-1..t_date)
    result_cargo_wokers = ResultCargoWorker.joins(:result_cargo).includes(:result_cargo).where(:work_date=>t_date-1)
    wokers = Woker.get_latest(t_date,:inc_model=>:user)
    vt = VacationType.all.pluck(:base_no,:time_sheet_name).to_h
    vacations = Vacation.where(:vacation_day=>t_date,:login_id=>wokers.pluck(:login_id)).index_by(&:login_id)

    #== エクセル書式設定 Excel formatting
    col_width = 4.5
    header_format =  excel.get_format(bgcolor:'cyan',align:'center',border:true)
    body_text_format = excel.get_format(bgcolor:'white',align:'center',border:true)
    body_num_format = excel.get_format(bgcolor:'white',align:'center',border:true,props:{num_format: '0.0'})
    body_text_format.set_text_wrap
    body_num_format.set_text_wrap


    #==
    branches.each do |branch|
      table_data = []
      branch_name = branch.name
      worksheet = workbook.add_worksheet(branch_name)
      worksheet.merge_range('A1:B1', branch_name, body_text_format)
      worksheet.merge_range('C1:E1', "#{(t_date-1).strftime("%m/%d")}まで", body_text_format)
      worksheet.merge_range('F1:G1', "#{(t_date).strftime("%m/%d")}(見込み)", body_text_format)


      table_data << [
        ["氏名",
         "#{(t_date).strftime("%m/%d")}分の勤怠",
         "#{(t_date-2).strftime("%m/%d")}終了時点\nでの累積時間外",
         "#{(t_date-1).strftime("%m/%d")}当日の作業\nの予定時間外数",
         "#{(t_date-1).strftime("%m/%d")}終了時点\nでの予想累積時間外",
         "#{(t_date).strftime("%m/%d")}の配番先\nの予想時間外数",
         "#{(t_date).strftime("%m/%d")}終了時点\nでの予想累積時間外"
        ]
      ]
      wokers.where(:branch_cd=>branch.cd).order(:desp_index=>:asc).each do |w|
        next if w.user.blank?
        p_orver_time_summary = 0;
        p_orver_time_prev    = 0;
        p_orver_time_forecast= 0;

        login_id = w[:login_id]

        if wt = t_tarm_wt_aggs_hash[login_id]
          p_orver_time_summary = wt[0]
          p_orver_time_prev    = wt[1] # !(result_ cargo_wokers || cargo_wokers) && wt の場合に使用される Used in the case of !(result_cargo_wokers || cargo_wokers) && wt
        end

        # UAT297: 前日の時間外（Rcw or Cw)で計算 UAT297: Calculated using the previous day's overtime hours (RCW or CW).
        resources = result_cargo_wokers.where(:login_id=>login_id)
        if resources.blank?
          resources = cargo_wokers.where(:login_id=>login_id,:work_date=>t_date-1)
        end
        if resources.present?
          calc_result = Batche::WorkTimeAggregate.mk_worker_sum({},resources,1)
          p_orver_time_prev = calc_result[:p_orver_time] + calc_result[:p_early_time]
        end



        # 配番作業員の予定時間外数を計算 Calculate the number of overtime hours for assigned workers.
        row_data = Array.new(7,"")
        row_data[0] = w.user[:name]
        vac = vacations[w.login_id]
        row_data[1]  = (vac.present? ? vt[vac.base_no] : "")
        row_data[2] = p_orver_time_summary.to_i>0 ? (1.0*p_orver_time_summary)/60 : 0
        row_data[3] = p_orver_time_prev.to_i>0 ? (1.0*p_orver_time_prev)/60 : 0
        row_data[4] = "=$C#{table_data.length+2}+$D#{table_data.length+2}" # [2] + [3]
        row_data[5] = 0
        row_data[6] = "=$E#{table_data.length+2}+$F#{table_data.length+2}"# [4] + [5]
        
        cws = cargo_wokers.where(:login_id=>login_id,:work_date=>t_date)
        if cws.present?
          wk_sum = Batche::WorkTimeAggregate.mk_worker_sum({},cws,1)
          if wk_sum.present?
            orver_time_forecast = wk_sum[:p_orver_time] + wk_sum[:p_early_time]
            row_data[1] = "" # 配番されていた場合、休暇があっても非表示 # If assigned, vacation days will not be displayed.
            row_data[5] = (1.0*orver_time_forecast)/60 if orver_time_forecast.to_i>0
          end
        end
        table_data << row_data
      end

      # テーブルデータ書き込み Write table data
      offset = [0,1]
      data = table_data
      x_offset = 0 + offset[0]
      y_offset = 0 + offset[1]
      data.each_with_index do |dr,row_index|
        dr.each_with_index do |val,col_index|
          r_row = row_index + y_offset
          r_col = col_index + x_offset
          worksheet.write(r_row, r_col, val, body_num_format)
        end
      end
      # 列幅調整 Column width adjustment
      [# 開始列、終了列、横幅 Start column, end column, width
        [0,0,15],
        [1,1,10],
        [2,6,20],
      ].each {|s,e,size| worksheet.set_column(s,e,size)}
  
    end
    # エクセルファイル作成、保存 Create and save an Excel file.
    excel_path = excel.fin()
    return excel_path
  end
  
  
  #== fm/op/運転を取得 Obtain FM/OP/Operation
  def get_woker_type()
    w_type = self[:w_type]
    case w_type
    when 1 then
      return :fm
    when 2  then
      return  :op
    when 3 then
      return  :wk
    when -1,nil
      return nil
    else
      return nil
    end
  end

  #===表示対象日取得（SwitchTime以降は翌日、以前は当日 Get the date to display (the next day after SwitchTime, the same day before)
  def self.get_today
    today = Date.today
    if Time.now.hour >= SwitchTime[0] && Time.now.min > SwitchTime[1]
      return (today+1)
    else
      return today
      # return (today+1)
    end
  end

  def self.get_latest(t_date=Date.today(),inc_model:nil)
    applicable = Applicable.get_applicable(2,t_date)
    if inc_model
      wokers = Woker.includes(inc_model).where(:applicable=>[nil,applicable]).order(:branch_cd,:desp_index)
    else
      wokers = Woker.where(:applicable=>[nil,applicable]).order(:branch_cd,:desp_index)
    end
    wokers
  end

  # スコープ scope
  scope :cargo_woker, -> { where(:branch_cd=>%w(1 2 3 4)) } 



end
