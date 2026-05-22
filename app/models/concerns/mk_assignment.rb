# coding: utf-8
#=自動配番モジュール Automatic numbering module
module MkAssignment
  SimLoopCount = 32
  #
  #経過メッセージを作成 Create progress message
  def mk_msg(queue)
    job = DelayedJob.find_by_queue(queue)
    msg = DelayedJobMsg.find_by_delayed_job_id(job[:id])
    if msg.blank?
      msg = DelayedJobMsg.new({:delayed_job_id=>job[:id],:queue=>job[:queue]})
    end
    msg
  end
  #
  #前回FM配番のコピー Copy of the previous FM numbering
  def copy_fm(queue,work_date)
    work_date = Date.strptime(work_date, "%Y%m%d")
    used_cargo_ids = []

    msg = mk_msg(queue)
    msg[:msg] = "前回FM配番のコピー開始\n" ; msg.save!
    cargo_tbl = Cargo.where({:work_date=>work_date})
    cargo_tbl.each{|c|
      next if c[:esta_flg] == 9 #荷役不成立の場合は自動配番をスキップ If cargo handling is unsuccessful, automatic assignment is skipped.
      msg[:msg] << "[#{c[:work_no]}][#{c[:work_name]}][(#{c[:work_cd]})#{c[:cargo_name]}]\n" ; msg.save!
      # 前回作業の同work_name,work_cdの作業を取得 Retrieve the work with the same work_name and work_cd from the previous operation.
      root_cg = Cargo.where(["work_date < ? and work_name = ? and work_cd=?",work_date,c[:work_name],c[:work_cd]]).order(:work_date=>:desc).first
      # 前回作業同日の同work_name,work_cdの作業を再取得(※used_cargo_idsを除外) Re-retrieve the work for the same work_name and work_cd on the same day as the previous work (excluding used_cargo_ids).
      root_cg = Cargo.where(["work_date = ? and work_name = ? and work_cd=?",root_cg[:work_date],c[:work_name],c[:work_cd]]).where.not(id: used_cargo_ids).order(:desp_index=>:asc).first if root_cg.present?


      if root_cg.blank?
        msg[:msg] << "前回作業なしのためスキップ\n" ; msg.save!
      else
        loop_count = 0
        loop_count_max = c[:fm_m].to_i
        root_wkrs = root_cg.cargo_worker.where(:wk_type=>"fm")
        root_wkrs.each{|root_wkr|
          next if loop_count >= loop_count_max
          s_time = c[:i_time].present? ? WorkTimeAggregate.mk_time(work_date,c[:i_time],c[:i_time]) : nil
          e_time = c[:e_time].present? ? WorkTimeAggregate.mk_time(work_date,c[:e_time],c[:e_time]) : nil

          #休暇チェック vacation check
          v = Vacation.find_by(:login_id=>root_wkr[:login_id],:vacation_day=>work_date)
          if v.present?
            vacation_day = v[:vacation_day]
            base_no = v[:base_no]
            arriv_time = v[:arriv_time]
            leav_time  = v[:leav_time]
            case base_no
            when 2,3,31,32,33,34,41,42
              # 出勤時間 Working hours
              if arriv_time.present?
                arriv_time = WorkTimeAggregate.mk_time(vacation_day,arriv_time,arriv_time)
                s_time = arriv_time if s_time.blank? || (arriv_time > s_time)
              end
              # 終了時間 End time
              if leav_time.present?
                leav_time = WorkTimeAggregate.mk_time(vacation_day,leav_time,leav_time)
                e_time = leav_time if e_time.blank? || (leav_time < e_time)
              end
            when 6
              next if v[:at_work].to_i != 1
            else
              next
            end
          end

          wkr = CargoWorker.find_by({:cargo_id=>c[:id],:work_date=>work_date,:wk_type=>"fm",:wk_index=>root_wkr[:wk_index]})
          if wkr.blank?
            wkr = CargoWorker.new({
              :cargo_id => c[:id],
              :work_date => work_date,
              :wk_type => "fm",
              :wk_index => root_wkr[:wk_index],
              :work_index => 0,
              :bus_flg => 0,
              :wk_class => "fm",
              :created_uid => "batch",
            })
          end
          [:user_id,:login_id,:work_class,:competence].each{|key| wkr[key] = root_wkr[key]}
          wkr[:s_time] = s_time.present? ? s_time : nil
          wkr[:e_time] = e_time.present? ? e_time : nil
          if wkr[:s_time].present? && wkr[:e_time].present?
            wkr[:work_time] , wkr[:orver_time] = WorkTimeAggregate.calc_legal_work_time(work_date,wkr[:s_time],wkr[:e_time],wkr[:bus_flg])
          else
            wkr[:work_time] = 0
            wkr[:orver_time] = 0
          end
          wkr[:lock_flg]=1
          wkr[:updated_uid] = "batch"
          wkr.save
          loop_count += 1
        }
        used_cargo_ids << root_cg[:id]
      end
    }
    msg[:msg] = "前回FM配番のコピー完了\n" ; msg.save!

  end

  #
  #前回DM配番のコピー Copy of previous DM number
  def copy_dm(queue,work_date)
    work_date = Date.strptime(work_date, "%Y%m%d")
    used_cargo_ids = []

    msg = mk_msg(queue)
    msg[:msg] = "前回DM配番のコピー開始\n" ; msg.save!
    cargo_tbl = Cargo.where({:work_date=>work_date})
    cargo_tbl.each{|c|
    next if c[:esta_flg] == 9 #荷役不成立の場合は自動配番をスキップ Skip automatic numbering if cargo handling is unsuccessful
    # 前回作業の同work_name,work_cdの作業を取得  Get the work with the same work_name and work_cd of the previous work
    root_cg = Cargo.where(["work_date < ? and work_name = ? and work_cd=?",work_date,c[:work_name],c[:work_cd]]).order(:work_date=>:desc).first
    # 前回作業同日の同work_name,work_cdの作業を再取得(※used_cargo_idsを除外) Re-acquire the work of the same work_name and work_cd on the same day as the previous work (*excluding used_cargo_ids)
    root_cg = Cargo.where(["work_date = ? and work_name = ? and work_cd=?",root_cg[:work_date],c[:work_name],c[:work_cd]]).where.not(id: used_cargo_ids).order(:desp_index=>:asc).first if root_cg.present?

    msg[:msg] << "[#{c[:work_no]}][#{c[:work_name]}][(#{c[:work_cd]})#{c[:cargo_name]}]\n" ; msg.save!
    if root_cg.blank?
        msg[:msg] << "前回作業なしのためスキップ\n" ; msg.save!
      else
        loop_count = 0
        loop_count_max = c[:dm_m].to_i
        root_wkrs = root_cg.cargo_worker.where(:wk_type=>"dm")
        root_wkrs.each{|root_wkr|
          next if loop_count >= loop_count_max
          s_time = c[:i_time].present? ? WorkTimeAggregate.mk_time(work_date,c[:i_time],c[:i_time]) : nil
          e_time = c[:e_time].present? ? WorkTimeAggregate.mk_time(work_date,c[:e_time],c[:e_time]) : nil

          #休暇チェック vacation check
          v = Vacation.find_by(:login_id=>root_wkr[:login_id],:vacation_day=>work_date)
          if v.present?
            vacation_day = v[:vacation_day]
            base_no = v[:base_no]
            arriv_time = v[:arriv_time]
            leav_time  = v[:leav_time]
            case base_no
            when 2,3,31,32,33,34,41,42
              # 出勤時間 Working hours
              if arriv_time.present?
                arriv_time = WorkTimeAggregate.mk_time(vacation_day,arriv_time,arriv_time)
                s_time = arriv_time if s_time.blank? || (arriv_time > s_time)
              end
              # 終了時間 End time
              if leav_time.present?
                leav_time = WorkTimeAggregate.mk_time(vacation_day,leav_time,leav_time)
                e_time = leav_time if e_time.blank? || (leav_time < e_time)
              end
            when 6
              next if v[:at_work].to_i != 1
            else
              next
            end
          end

          wkr = CargoWorker.find_by({:cargo_id=>c[:id],:work_date=>work_date,:wk_type=>"dm",:wk_index=>root_wkr[:wk_index]})
          if wkr.blank?
            wkr = CargoWorker.new({
              :cargo_id => c[:id],
              :work_date => work_date,
              :wk_type => "dm",
              :wk_index => root_wkr[:wk_index],
              :work_index => 0,
              :bus_flg => 0,
              :wk_class => "dm",
              :created_uid => "batch",
            })
          end
          [:user_id,:login_id,:work_class,:competence].each{|key| wkr[key] = root_wkr[key]}
          wkr[:s_time] = s_time.present? ? s_time : nil
          wkr[:e_time] = e_time.present? ? e_time : nil
          if wkr[:s_time].present? && wkr[:e_time].present?
            wkr[:work_time] , wkr[:orver_time] = WorkTimeAggregate.calc_legal_work_time(work_date,wkr[:s_time],wkr[:e_time],wkr[:bus_flg])
          else
            wkr[:work_time] = 0
            wkr[:orver_time] = 0
          end
          wkr[:lock_flg]=1
          wkr[:updated_uid] = "batch"
          wkr.save
          loop_count += 1
        }
        used_cargo_ids << root_cg[:id]
      end
    }
    msg[:msg] = "前回DM配番のコピー完了\n" ; msg.save!
  end

  #
  #自動配番 Automatic numbering
  def auto_assignment(queue,work_date)
    msg = mk_msg(queue)
    msg[:msg] = "自動配番開始\n" ; msg.save!
    work_date = Date.strptime(work_date, "%Y%m%d")
    whs = WhSummary.find_by(["? between s_date and e_date",work_date])
    excluded_users = []  #除外ユーザ（配番済みor完全休暇ユーザ） Excluded users (assigned or completely vacation users)
    registered_machines = [] #配番済み機械 Assigned machines
    #乱数初期化 Random number initialization
    random = Random.new()
    msg[:msg] << "配番データをロード\n" ; msg.save!
    cargos = {} ; cargo_ids = {0=>[],1=>[],:all=>[]}
    cargo_tbl = Cargo.where({:work_date=>work_date}).includes([:cargo_worker,:cargo_machine])
    cargo_tbl.each{|c|
      next if c[:esta_flg] == 9 #荷役不成立の場合は自動配番をスキップ Skip automatic numbering if cargo handling is unsuccessful
      case c[:move_no]
      when "HB999991","HB000600","HB000610"
        cargo_ids[0] << c[:id]
      else
        cargo_ids[1] << c[:id]
      end
      cargo_ids[:all] << c[:id]
      c_data = {:workers=>{},:machines=>{}}
      c.attribute_names.each{|key|
        case key
        when "cargo_request_id","note","matter1","matter2","momo_fm","momo_dm","momo_mc","momo_wi","momo_dr","momo_wk",
              "ob_np","hh_np","rk_np","wk_np","esta_flg","conf_flg",
              "lock_version","created_at","created_uid","updated_at","updated_uid","deleted_at","deleted_uid"
              #スキップ
        else
          c_data[key] = c[key]
        end
      }
      #配番済み作業者 Assigned worker
      c_worker_locked = c.cargo_worker.where(:lock_flg=>1)
      c_worker_locked.each{|worker|
        c_data[:workers]["#{worker[:wk_type]}_#{worker[:wk_class]}"] ||= []
        excluded_users << worker[:login_id]
        c_worker = {}
        worker.attribute_names.each{|key|
          case key
          when "id","lock_version","created_at","created_uid","updated_at","updated_uid","deleted_at","deleted_uid"
            #スキップ skip
          else
            c_worker[key.to_sym] = worker[key]
          end
        }
        c_data[:workers]["#{worker[:wk_type]}_#{worker[:wk_class]}"] << c_worker
      }
      #配番済み機械（機械はロック有無にかかわらず取込み Number picking machine (equipment can be loaded regardless of whether it is locked or not)
      c.cargo_machine.each{|machine|
        c_data[:machines][machine[:wk_type]] ||= {}
        c_data[:machines][machine[:wk_type]][machine[:wk_index]] = machine
        registered_machines << machine[:machine_id]
      }
      c_data[:need_count] = 0
      Cargo::WokerNumKey.each{|num_key|
        c_data[:need_count] += c_data[num_key].to_i
      }
      cargos[c[:id]] = c_data
    }unless cargo_tbl.blank?
    msg[:msg] << "作業員データをロード\n" ; msg.save!
    worker_list = {}; competence_list = {}
    #該当日休暇ユーザ取得 Acquire vacation user for the corresponding day
    has_v_user = {}       #早退or公休〇の作業員リスト、配番ではできるだけ選択しないようにする List of workers who leave early or take public holidays, avoid selecting them as much as possible when assigning numbers
    vacations = Vacation.where(["vacation_day=? ",work_date])
    vacations.each{|v|
      case v[:base_no]
      when 2,3,31,32,33,34,41,42
        has_v_user[v[:login_id]] = {:vacation_day=>v[:vacation_day], :base_no=>v[:base_no], :leav_time=>v[:leav_time], :arriv_time=>v[:arriv_time]}
      when 6
        if v[:at_work]==1
          has_v_user[v[:login_id]] = {:base_no=>v[:base_no]}
        else
          excluded_users << v[:login_id]
        end
      else
        excluded_users << v[:login_id]
      end
    }
    #当月残業時間集計 Total overtime hours for the current month
    total_work_time = CargoWorker.total_work_times(work_date,{:begin_date=>whs[:s_date],:end_date=>whs[:e_date]})
    #配番可能ユーザをロード Load numberable users
    applicable = Applicable.get_applicable(2,work_date)
    woker_info = {}
    woker_competences1 = {}  #正規作業員 regular worker
    woker_competences2 = {}  #副作業員 Deputy worker
    Woker::CompetenceKey.each{|c|woker_competences1[c]={};woker_competences2[c]={};}
    data_tbl = Woker.where(["applicable=? and not login_id in(?)",applicable,excluded_users]).order(:desp_index)
    data_tbl = Woker.includes([:user]).where(["applicable=? and not login_id in(?)",applicable,excluded_users]).order(:desp_index)
    data_tbl.each{|data_lin|
      #case data_lin[:branch_cd]
      #when "1","2","3","4"
        Woker::CompetenceKey.each{|c|
          if data_lin["competence_#{c}"].to_i > 0
            if c=="ca"
              woker_competences1[c][data_lin[:branch_cd]] ||= {}
              woker_competences1[c][data_lin[:branch_cd]][data_lin[:login_id]]=data_lin["competence_#{c}"]
            else
              woker_competences1[c][data_lin[:login_id]]=data_lin["competence_#{c}"]
            end
          end
        }
      #else
      #  Woker::CompetenceKey.each{|c|
      #    if data_lin["competence_#{c}"].to_i > 0
      #      woker_competences2[c][data_lin[:login_id]]=data_lin["competence_#{c}"]
      #    end
      #  }
      #end
      woker_info[data_lin[:login_id]] = {
        :user_id => (data_lin.user.present? ? data_lin.user[:id] : 0),
        :branch_cd => data_lin[:branch_cd],
        :vacation => (has_v_user.has_key?(data_lin[:login_id]) ? has_v_user[data_lin[:login_id]] : nil),
        :total_work_time => (total_work_time.has_key?(data_lin[:login_id]) ? total_work_time[data_lin[:login_id]] : {}),
        :cargo_ids => []
      }
    }
    #配番優先ユーザデータをロード Load numbering priority user data
    ca_workers = {}
    if cargo_ids[0].include?("HB999991")
      data_tbl = Woker.where(["applicable=? and competence_ca >4 ",applicable]).order(:desp_index)
      data_tbl.each{|data_lin|
        unless ca_workers.has_key(data_lin[:branch_cd])
          ca_workers[data_lin[:branch_cd]] = data_lin[:login_id]
        end
      }
    end
    msg[:msg] << "機械データをロード\n" ; msg.save!
    machines,machine_names,machine_bgc_class = Machine.get_assignment_list(work_date)
    #配番 Number assignment
    
    msg[:msg] << "機械配番を実行\n" ; msg.save!
    #-- 機械列の自動配番 -- (20241206_大澤追加) Automatic numbering of machine rows -- (20241206_Osawa added)
    cargos.each{|cargo_id,c_data|
      c_mc_name = c_data["machine_nm"]
      next if c_mc_name.blank?
      #-- 選定条件 Selection conditions
      #   配番の機械名と一致する機械名を探す Search for a matching machine name
      #   重複チェックはしない No duplicate checking
      candidate = Machine.where("cd = ? OR name = ?",c_mc_name,c_mc_name)&.first
      next if candidate.blank?

      #- 固定値 Fixed value
      wk_index = 1 # 1枠で固定のため Because it is fixed in one frame
      wk_type = "mc"

      #- 登録予約 Registration reservation
      c_data[:machines] ||= {}; c_data[:machines]["mc"] ||= {} 
      c_data[:machines]["mc"][wk_index] = {
        :cargo_id => c_data["id"],
        :work_date => c_data["work_date"],
        :machine_id => candidate[:id],
        :machine_cd => candidate[:cd],
        :wk_type => wk_type,
        :wk_index => wk_index,
        :work_time => c_data["work_time"],
        :m_type => candidate[:m_type],
      }
    }
    #-- -- -- -- - -- --  
    cargo_class = {
      :cargo_class09=>["肥料"],
      :cargo_class23_3818=>["PKS","パーム椰子殻","ﾊﾟｰﾑ椰子殻"],
      :cargo_class23_3816=>["ﾍﾟﾚｯﾄ","ペレット"],
      :cargo_class12=>["工業塩"],
      :cargo_class01=>["石炭"],
      :cargo_class06=>["亜鉛鉱"],
      :cargo_class05=>["ｺｰｸｽ","コークス"],
      :cargo_class07=>["銅精鉱"],
      :cargo_class98=>["ｺﾝﾃﾅ","コンテナ"],
      :cargo_class17=>["ｽｸﾗｯﾌﾟ","スクラップ"],
    }
    #優先・可能を配番 Priority and possible assignment
    [2,1].each{|level|
      machines.each{|m_type,mlist|
        cargo_class.each{|wkcd,key_wds|
          tlist = mlist.select{|m| m[wkcd] == level && m[:u_maintenance] == 0 && m[:mainte].nil? && !registered_machines.include?(m[:id])}
          if tlist.present?
            #場所指定で場合分け Case of place specification
            plist = {:blank => []}
            tlist.each{|m|
              has_place = false
              1.upto(3){|wi|
                p_key = "wk_place#{wi}".to_sym
                if m[p_key].present?
                  plist[m[p_key]] = [] unless plist.has_key?(m[p_key])
                  plist[m[p_key]] << m
                  has_place = true
                end
              }
              plist[:blank] << m unless has_place
            }
            #作業データを走査 Survey work data
            cargos.each{|cargo_id,c_data| 
              if c_data["cargo_name"].present? && key_wds.any?{|key_wd| c_data["cargo_name"].include?(key_wd)}
                if c_data["#{m_type}_m"].to_i > 0 || m_type == "ot"
                  candidates = nil
                  plist.each{|place,tmlist|
                    next if place == :blank
                    if c_data["work_place"].include?(place)
                      candidates = tmlist
                      has_place = true
                      break
                    end
                  }
                  candidates = plist[:blank] if candidates.nil?
                  unless candidates.blank?
                    registered = 0
                    if c_data["#{m_type}_m"].to_i > 0  #<-必要人数あり＝取扱者 Required number of workers
                      if c_data[:machines].has_key?("dr")
                        registered = c_data[:machines]["dr"].count{|idx,rm| rm[:m_type] == m_type}
                      else
                        c_data[:machines]["dr"] = {}
                      end
                      registered.upto(c_data["#{m_type}_m"]-1){
                        wk_index = 1
                        while c_data[:machines]["dr"].has_key?(wk_index)
                          if c_data[:machines]["dr"][wk_index][:m_type] == m_type
                            wk_index += 2
                          else
                            wk_index += 6
                          end
                          break if wk_index > 40
                        end
                        candidate = candidates[random.rand(candidates.size)]
                        c_data[:machines]["dr"][wk_index] = {
                          :cargo_id => c_data["id"],
                          :work_date => c_data["work_date"],
                          :machine_id => candidate[:id],
                          :machine_cd => candidate[:cd],
                          :wk_type => "dr",
                          :wk_index => wk_index,
                          :work_time => c_data["work_time"],
                          :m_type => m_type,
                        }
                        #候補リストから削除 Delete from candidate list
                        registered_machines << candidate[:id]
                        candidates.delete(candidate)
                        mlist.delete(candidate)
                        break if candidates.blank?
                      }
                    elsif c_data["sn_w"].to_i > 0
                      if c_data[:machines].has_key?("wk")
                        registered = c_data[:machines]["wk"].count{|idx,rm| rm[:m_type] == m_type}
                      else
                        c_data[:machines]["wk"] = {}
                      end
                      registered.upto((c_data["sn_w"]/2)-1){
                        wk_index = 1
                        while c_data[:machines]["wk"].has_key?(wk_index)
                          wk_index += 2
                          break if wk_index > 40
                        end
                        candidate = candidates[random.rand(candidates.size)]
                        c_data[:machines]["wk"][wk_index] = {
                          :cargo_id => c_data["id"],
                          :work_date => c_data["work_date"],
                          :machine_id => candidate[:id],
                          :machine_cd => candidate[:cd],
                          :wk_type => "wk",
                          :wk_index => wk_index,
                          :work_time => c_data["work_time"],
                          :m_type => m_type,
                        }
                        #候補リストから削除 Delete from candidate list
                        registered_machines << candidate[:id]
                        candidates.delete(candidate)
                        mlist.delete(candidate)
                        break if candidates.blank?
                      }
                    end
                  end
                end
              end
            }
          end
        }
      }
    }
    #場所のみ指定機械を配番 Place only machine assignment
    machines.each{|m_type,mlist|
      tlist = mlist.select{|m| (m[:wk_place1].present? || m[:wk_place2].present? || m[:wk_place3].present?) && m[:u_maintenance] == 0 && m[:mainte].nil? && !registered_machines.include?(m[:id])}
      unless tlist.blank?
        #場所指定で場合分け Case of place specification
        plist = {}
        tlist.each{|m|
          has_place = false
          1.upto(3){|wi|
            p_key = "wk_place#{wi}".to_sym
            if m[p_key].present?
              plist[m[p_key]] = [] unless plist.has_key?(m[p_key])
              plist[m[p_key]] << m
            end
          }
        }
        #作業データを走査 Survey work data
        cargos.each{|cargo_id,c_data| 
          if c_data["work_place"].present?
            if c_data["#{m_type}_m"].to_i > 0 || m_type == "ot"
              candidates = nil
              plist.each{|place,tmlist|
                if c_data["work_place"].include?(place)
                  candidates = tmlist
                  break
                end
              }
              unless candidates.blank?
                registered = 0
                if c_data["#{m_type}_m"].to_i > 0  #<-必要人数あり＝取扱者  #<-Required number of people=handlers
                  if c_data[:machines].has_key?("dr")
                    registered = c_data[:machines]["dr"].count{|idx,rm| rm[:m_type] == m_type}
                  else
                    c_data[:machines]["dr"] = {}
                  end
                  registered.upto(c_data["#{m_type}_m"]-1){
                    wk_index = 1
                    while c_data[:machines]["dr"].has_key?(wk_index)
                      if c_data[:machines]["dr"][wk_index][:m_type] == m_type
                        wk_index += 2
                      else
                        wk_index += 6
                      end
                      break if wk_index > 40
                    end
                    candidate = candidates[random.rand(candidates.size)]
                    c_data[:machines]["dr"][wk_index] = {
                      :cargo_id => c_data["id"],
                      :work_date => c_data["work_date"],
                      :machine_id => candidate[:id],
                      :machine_cd => candidate[:cd],
                      :wk_type => "dr",
                      :wk_index => wk_index,
                      :work_time => c_data["work_time"],
                      :m_type => m_type,
                    }
                    #候補リストから削除 Delete from candidate list
                    registered_machines << candidate[:id]
                    candidates.delete(candidate)
                    mlist.delete(candidate)
                    break if candidates.blank?
                  }
                elsif c_data["sn_w"].to_i > 0
                  if c_data[:machines].has_key?("wk")
                    registered = c_data[:machines]["wk"].count{|idx,rm| rm[:m_type] == m_type}
                  else
                    c_data[:machines]["wk"] = {}
                  end
                  registered.upto((c_data["sn_w"]/2)-1){
                    wk_index = 1
                    while c_data[:machines]["wk"].has_key?(wk_index)
                      wk_index += 2
                      break if wk_index > 40
                    end
                    candidate = candidates[random.rand(candidates.size)]
                    c_data[:machines]["wk"][wk_index] = {
                      :cargo_id => c_data["id"],
                      :work_date => c_data["work_date"],
                      :machine_id => candidate[:id],
                      :machine_cd => candidate[:cd],
                      :wk_type => "wk",
                      :wk_index => wk_index,
                      :work_time => c_data["work_time"],
                      :m_type => m_type,
                    }
                    #候補リストから削除 Delete from candidate list
                    registered_machines << candidate[:id]
                    candidates.delete(candidate)
                    mlist.delete(candidate)
                    break if candidates.blank?
                  }
                end
              end
            end
          end
        }
      end
    }
    #他取扱者機械を配番 Assign other handlers' machines
    cargos.each{|cargo_id,c_data|
      machines.each{|m_type,mlist|
        next if m_type=="ot" || m_type=="bs"
        if c_data.has_key?("#{m_type}_m") && c_data["#{m_type}_m"].to_i > 0
          registered = 0
          if c_data[:machines].has_key?("dr")
            registered = c_data[:machines]["dr"].count{|idx,rm| rm[:m_type] == m_type}
          else
            c_data[:machines]["dr"] = {}
          end
          candidates = mlist.select{|m| m[:u_maintenance] == 0 && m[:mainte].nil? && !registered_machines.include?(m[:id])}
          registered.upto(c_data["#{m_type}_m"]-1){|co|
            wk_index = 1
            while c_data[:machines]["dr"].has_key?(wk_index)
              if c_data[:machines]["dr"][wk_index][:m_type] == m_type
                wk_index += 2
              else
                wk_index += 6
              end
              break if wk_index > 40
            end
            candidate = candidates[random.rand(candidates.size)]
            c_data[:machines]["dr"][wk_index] = {
              :cargo_id => c_data["id"],
              :work_date => c_data["work_date"],
              :machine_id => candidate[:id],
              :machine_cd => candidate[:cd],
              :wk_type => "dr",
              :wk_index => wk_index,
              :work_time => c_data["work_time"],
              :m_type => m_type,
            }
            #候補リストから削除 Delete from candidate list
            registered_machines << candidate[:id]
            candidates.delete(candidate)
            mlist.delete(candidate)
            break if candidates.blank?
          }
        end
      }
    }
    msg[:msg] << "自動配番を実行\n" ; msg.save!
    sym_ret = {}
    1.upto(SimLoopCount){|sim_no|
      wk_cargos = Marshal.load(Marshal.dump(cargos))
      wk_wokers = Marshal.load(Marshal.dump(woker_competences1))
      wk_winfo = Marshal.load(Marshal.dump(woker_info))
      case (sim_no % 4)
      when 1
        #配番、車両整備、道具（６号）→本船→沿岸  Numbering, vehicle maintenance, tools (No. 6) → Ship → Coast
        cid_list = cargo_ids[0] + cargo_ids[1]
      when 2
        #超過時間の昇順 Ascending order of overtime
        cid_list = cargo_ids[:all].sort_by{|cid|  wk_cargos[cid]["orver_time"] }
      when 3
        #超過時間の降順 Descending order of overtime
        cid_list = cargo_ids[:all].sort_by{|cid|  wk_cargos[cid]["orver_time"] * -1 }
      when 0
        #配番、車両整備、道具（６号）→沿岸→本船 Numbering, vehicle maintenance, tools (No. 6) → Coast → Vessel
        cid_list = cargo_ids[0] + cargo_ids[1].sort_by{|cid|  wk_cargos[cid]["work_no"] * -1 }
      end
      cid_list.each{|cargo_id|
        c_data = wk_cargos[cargo_id]
        case c_data["move_no"]
        when "HB999991"
          #力量キー competency key
          c_key="ca"
          #配番済みグループを除外 competency key
          branch_cds = ["1","2","3","4"]
          c_data[:workers].each{|type_class,workers|
            workers.each{|worker|
              if wk_winfo.has_key?(worker[:login_id])
                branch_cds.delete(wk_winfo[worker[:login_id]][:branch_cd])
              end
            }
          }
          Cargo::WokerNumKey.each{|num_key|
            if c_data[num_key].to_i > 0
              wk_type , wk_class = get_wk_type_class(num_key)
              if c_data[:workers].has_key?("#{wk_type}_#{wk_class}")
                registered = c_data[:workers]["#{wk_type}_#{wk_class}"].size
              else
                registered = 0
                c_data[:workers]["#{wk_type}_#{wk_class}"] = []
              end
              (c_data[num_key] - registered).times{
                #対象グループCDを絞る Narrow down target group CDs
                if branch_cds.blank?
                  branch_cds = wk_wokers[c_key].keys
                  branch_cd = branch_cds[random.rand(branch_cds.size)]
                else
                  branch_cd = branch_cds[0]
                  branch_cds.delete(branch_cd)
                end
                #配番は以下の方が最優先 Priority is given to the following for numbering:
                t_login_id = "dummy"
                t_login_id = ca_workers[branch_cd] if ca_workers.has_key?(branch_cd)
                if wk_wokers[c_key][branch_cd].blank?
                  if branch_cd == "2"
                    t_login_id = choice_worker(random,c_data,wk_wokers[c_key]["1"],wk_winfo)
                    if t_login_id.nil?
                      c_data[:workers]["#{wk_type}_#{wk_class}"] << {:d=>"d"}
                    else
                      cargo_worker = mk_cargo_worker(c_data,t_login_id,wk_winfo[t_login_id],wk_wokers[c_key]["1"],wk_type , wk_class,0)
                      c_data[:workers]["#{wk_type}_#{wk_class}"] << cargo_worker
                      wk_wokers = delete_competences(wk_wokers,t_login_id)
                    end
                  elsif branch_cd == "4"
                    t_login_id = choice_worker(random,c_data,wk_wokers[c_key]["3"],wk_winfo)
                    if t_login_id.nil?
                      c_data[:workers]["#{wk_type}_#{wk_class}"] << {:d=>"d"}
                    else
                      cargo_worker = mk_cargo_worker(c_data,t_login_id,wk_winfo[t_login_id],wk_wokers[c_key]["3"],wk_type , wk_class,0)
                      c_data[:workers]["#{wk_type}_#{wk_class}"] << cargo_worker
                      wk_wokers = delete_competences(wk_wokers,t_login_id)
                    end
                  else
                    c_data[:workers]["#{wk_type}_#{wk_class}"] << {:d=>"d"}
                  end
                elsif wk_wokers[c_key][branch_cd].include?(t_login_id)
                  cargo_worker = mk_cargo_worker(c_data,t_login_id,wk_winfo[t_login_id],wk_wokers[c_key][branch_cd],wk_type , wk_class,0)
                  c_data[:workers]["#{wk_type}_#{wk_class}"] << cargo_worker
                  wk_wokers = delete_competences(wk_wokers,t_login_id)
                else
                  tmp_list = Marshal.load(Marshal.dump(wk_wokers[c_key][branch_cd]))
                  tmp_list = {} if tmp_list.nil?
                  case branch_cd
                  when "2" ; tmp_list = tmp_list.merge(wk_wokers[c_key]["1"]) unless wk_wokers[c_key]["1"].blank?
                  when "4" ; tmp_list = tmp_list.merge(wk_wokers[c_key]["3"]) unless wk_wokers[c_key]["1"].blank?
                  end
                  t_login_id = choice_worker(random,c_data,tmp_list,wk_winfo)
                  if t_login_id.nil?
                    c_data[:workers]["#{wk_type}_#{wk_class}"] << {:d=>"d"}
                  else
                    cargo_worker = mk_cargo_worker(c_data,t_login_id,wk_winfo[t_login_id],tmp_list,wk_type , wk_class,0)
                    c_data[:workers]["#{wk_type}_#{wk_class}"] << cargo_worker
                    wk_wokers = delete_competences(wk_wokers,t_login_id)
                  end
                end
              }
            end
          }
        when "HB000600","HB000610"
          c_key= (c_data["move_no"] =="HB000600" ? "mt" : "tl")
          Cargo::WokerNumKey.each{|num_key|
            if c_data[num_key].to_i > 0
              wk_type , wk_class = get_wk_type_class(num_key)
              if c_data[:workers].has_key?("#{wk_type}_#{wk_class}")
                registered = c_data[:workers]["#{wk_type}_#{wk_class}"].size
              else
                registered = 0
                c_data[:workers]["#{wk_type}_#{wk_class}"] = []
              end
              (c_data[num_key] - registered).times{
                t_login_id = choice_worker(random,c_data,wk_wokers[c_key],wk_winfo)
                if t_login_id.nil?
                  t_login_id = choice_worker(random,c_data,woker_competences2[c_key],wk_winfo)
                end
                if t_login_id.nil?
                  break;
                else
                  cargo_worker = mk_cargo_worker(c_data,t_login_id,wk_winfo[t_login_id],wk_wokers[c_key],wk_type , wk_class,0)
                  c_data[:workers]["#{wk_type}_#{wk_class}"] << cargo_worker
                  wk_wokers = delete_competences(wk_wokers,t_login_id)
                end
              }
            end
          }
        else
          dr_needs = {} ; wk_needs = {} ; wk_indexs = {}
          Cargo::WokerNumKey.each{|num_key|
            if c_data[num_key].to_i > 0
              wk_type , wk_class = get_wk_type_class(num_key)
              c_data[:workers]["#{wk_type}_#{wk_class}"] ||= []
              if wk_type == "dr"
                dr_needs[wk_class] ||= {:m=>0,:s=>0,:t=>0}
                if num_key=~ /_m$/
                  dr_needs[wk_class][:m] += c_data[num_key]
                else
                  dr_needs[wk_class][:s] += c_data[num_key]
                end
                dr_needs[wk_class][:t] += c_data[num_key]
              elsif wk_type == "wk"
                wk_needs[wk_class] = c_data[num_key]
              else
                wk_indexs[wk_type] ||= 0
                registered = c_data[:workers]["#{wk_type}_#{wk_class}"].size
                wk_indexs[wk_type] = (registered + 1)
                (c_data[num_key] - registered).times{
                  c_key = get_competence_key(num_key,c_data,wk_indexs[wk_type],wk_type,wk_class)
                  t_login_id = choice_worker(random,c_data,wk_wokers[c_key],wk_winfo)
                  if t_login_id.nil?
                    t_login_id = choice_worker(random,c_data,woker_competences2[c_key],wk_winfo)
                  end
                  wk_indexs[wk_type] += 1
                  if t_login_id.nil?
                    break;
                  else
                    cargo_worker = mk_cargo_worker(c_data,t_login_id,wk_winfo[t_login_id],wk_wokers[c_key],wk_type , wk_class,0)
                    c_data[:workers]["#{wk_type}_#{wk_class}"] << cargo_worker
                    wk_wokers = delete_competences(wk_wokers,t_login_id)
                  end
                }
              end
            end
          }
          #dr:取扱者の処理 dr: Handler processing
          if dr_needs.present?
            wk_type = "dr"
            #登録済み機械データから配置 Placement from registered machine data
            wk_cargo_workers = {}
            c_data[:machines][wk_type].each{|wk_index,machine|
              if machine[:m_type]!="bs" && machine[:m_type]!="ot"
                if dr_needs[machine[:m_type]].present?
                  if dr_needs[machine[:m_type]][:m].to_i > 0
                    wk_cargo_workers[wk_index] = "#{machine[:m_type]}_m"
                    dr_needs[machine[:m_type]][:m] -=1
                  end
                  if dr_needs[machine[:m_type]][:s].to_i > 0 && !c_data[:machines][wk_type].has_key?((wk_index+1))
                    wk_cargo_workers[(wk_index+1)] = "#{machine[:m_type]}_s"
                    dr_needs[machine[:m_type]][:s] -=1
                  end
                end
              end 
            }unless c_data[:machines][wk_type].blank?
            #不足分を空いたところに詰める fill in the missing amount in the empty space
            dr_needs.each{|wk_class,need|
              if need[:m].to_i > 0 || need[:s].to_i > 0
                need[:m].times{|wi|
                  wk_index = 1
                  while wk_cargo_workers.has_key?(wk_index)
                    wk_index += 2
                    break if wk_index > 40
                  end
                  wk_cargo_workers[wk_index] = "#{wk_class}_m"
                }
                need[:s].times{|wi|
                  wk_index = 1
                  while wk_cargo_workers.has_key?(wk_index)
                    wk_index += 2
                    break if wk_index > 40
                  end
                  wk_cargo_workers[wk_index] = "#{wk_class}_s"
                }
              end
            }
            #登録済み作業員データを確認し、必要人数を削除&&作業設定からマークを削除 Check the registered worker data, delete the required number of workers & & delete the mark from work settings
            c_data[:workers].each{|type_class,workers|
              if type_class =~/^#{wk_type}/
                workers.each{|worker| 
                  num_key = wk_cargo_workers[worker[:wk_index]]
                  if num_key =~ /^(.*)_([m|s])$/
                    wk_class = $1
                    ms = $2
                    dr_needs[wk_class][ms.to_sym] -= 1
                    dr_needs[wk_class][:t] -= 1
                    wk_cargo_workers[worker[:wk_index]] = nil
                  end
                }
              end
            }
            wk_cargo_workers.each{|wk_index,num_key|
              if num_key =~ /^(.*)_([m|s])$/
                wk_class = $1
                ms = $2
                c_key = get_competence_key(num_key,c_data,wk_index,wk_type,wk_class)
                t_login_id = choice_worker(random,c_data,wk_wokers[c_key],wk_winfo)
                if t_login_id.nil?
                  t_login_id = choice_worker(random,c_data,woker_competences2[c_key],wk_winfo)
                end
                unless t_login_id.nil?
                  cargo_worker = mk_cargo_worker(c_data,t_login_id,wk_winfo[t_login_id],wk_wokers[c_key],wk_type,wk_class,wk_index)
                  c_data[:workers]["#{wk_type}_#{wk_class}"] << cargo_worker
                  wk_wokers = delete_competences(wk_wokers,t_login_id)
                end
              end
            }
          end
          if wk_needs.present?
            wk_type = "wk"
            wk_cargo_workers = {}
            #前から詰めた場合 When packed from the front
            wk_index = 1
            wk_needs.each{|wk_class,need|
              need.times{
                wk_cargo_workers[wk_index] = "#{wk_class}"
                wk_index += 1
              }
            }
            #登録済み機械データから調整 Adjustment from registered machine data
            c_data[:machines][wk_type].each{|wk_index,machine|
              if machine[:machine_cd]=~/ｽｲｰﾊﾟ/ || machine[:machine_cd]=~/散水/ || machine[:machine_cd]=~/掃除機/ || machine[:machine_cd]=~/三洋掃/
                tmp_wk_class = wk_cargo_workers[wk_index]
                wk_cargo_workers.size.downto(1){|tmp_index|
                  if wk_cargo_workers[tmp_index] == "ot"
                    wk_cargo_workers[tmp_index] = tmp_wk_class
                    wk_cargo_workers[wk_index] = "ot"
                    break;
                  end
                }
              end
            }unless c_data[:machines][wk_type].blank?
            #登録済み作業員データを確認し、必要人数を削除&&作業設定からマークを削除 Check the registered worker data, delete the required number of workers & & delete the mark from work settings
            c_data[:workers].each{|type_class,workers|
              if type_class =~/^#{wk_type}/
                workers.each{|worker| 
                  wk_class = wk_cargo_workers[worker[:wk_index]]
                  if wk_needs.has_key?(wk_class)
                    wk_needs[wk_class] -= 1
                  else
                    wk_needs[wk_class] = 0
                  end
                  wk_cargo_workers[worker[:wk_index]] = nil
                }
              end
            }
            wk_cargo_workers.each{|wk_index,wk_class|
              c_key = get_competence_key("#{wk_class}_w",c_data,wk_index,wk_type,wk_class)
              t_login_id = choice_worker(random,c_data,wk_wokers[c_key],wk_winfo)
              if t_login_id.nil?
                t_login_id = choice_worker(random,c_data,woker_competences2[c_key],wk_winfo)
              end
              unless t_login_id.nil?
                cargo_worker = mk_cargo_worker(c_data,t_login_id,wk_winfo[t_login_id],wk_wokers[c_key],wk_type,wk_class,wk_index)
                c_data[:workers]["#{wk_type}_#{wk_class}"] << cargo_worker
                wk_wokers = delete_competences(wk_wokers,t_login_id)
              end
            }
          end
        end
      }
      #評価 evaluation
      assessment = do_assessment(wk_cargos,wk_winfo)
      msg[:msg] << "自動配番#{sim_no}回目：未配番人数=[#{assessment[:shortage]}]、臨時=[#{assessment[:partners]}]、時間外偏差=[#{assessment[:orver_time_sd]}]\n"; msg.save!
      sym_ret[sim_no] = {
        :cargos => wk_cargos,
        :assessment => assessment,
      }
    }
    #評価もっともよい評価のシミュレーションを選択 Select the simulation with the best rating
    best_sym = choice_assessment(sym_ret)
    msg[:msg] << "#{best_sym}回目のシミュレーションを保存\n"; msg.save!
    begin
      CargoWorker.transaction do
        sym_ret[best_sym][:cargos].each{|cargo_id,c_data|
          CargoWorker.delete_all("batch",["cargo_id=? ",cargo_id])
          c_data[:workers].each{|type_class,workers|
            workers.each_with_index{|worker,wk_index|
              if worker.present? && worker[:login_id].present?
                worker[:wk_index] = (wk_index + 1) if worker[:wk_index] == 0
                CargoWorker.create_data([:cargo_id,:wk_type,:wk_index],worker,"batch",true,true)
              end
            }
          }
        }
        cargos.each{|cargo_id,c_data|
          c_data[:machines].each{|m_type,mlist|
            mlist.each{|idx,m|
              next if m[:id].present?
              CargoMachine.create_data([:cargo_id,:wk_type,:wk_index],m,"batch",true,true)
            }unless mlist.blank?
          }unless c_data[:machines].blank?
        }
      end
      
    rescue
      msg[:msg] << "<b class=err>保存処理エラー</b>\n"
      msg[:msg] << $!.to_s
      strlog = "-----\n"
      strlog << "error_msg:#{$!.to_s}\n"
      strlog << "backtrace\n"
      strlog << $!.backtrace.join("\n")
      Rails.logger.error(strlog)
      ExceptionNotifier.notify_exception($!)
      raise StandardError.new($!)
    end
    msg[:msg] << "自動配番完了\n" ; msg.save!
  end
  #必要人数カラム名から作業カテゴリ、担当作業を取得  Get the work category and work in charge from the required number of people column name
  def get_wk_type_class(num_key)
    case num_key
    when "fm_m" ; return ["fm","fm"];
    when "dm_m" ; return ["dm","dm"];
    when "wm_m" ; return ["wi","wm"];
    when "cr_m" ; return ["wi","cr"];
    when "ld_m","ld_s" ; return ["dr","ld"];
    when "bh_m","bh_s" ; return ["dr","bh"];
    when "sl_m","sl_s" ; return ["dr","sl"];
    when "bl_m","bl_s" ; return ["dr","bl"];
    when "lf_m","lf_s" ; return ["dr","lf"];
    when "sc_m","sc_s" ; return ["dr","sc"];
    when "tl_m","tl_s" ; return ["dr","tl"];
    when "ot_m" ; return ["dr","ot"];
    when "hd_w" ; return ["wk","hd"];
    when "db_w" ; return ["wk","db"];
    when "hs_w" ; return ["wk","hs"];
    when "sn_w" ; return ["wk","sn"];
    when "eg_w" ; return ["wk","eg"];
    when "ot_w" ; return ["wk","ot"];
    else  ; return ["-","-"];
    end
  end
  #荷役従事者データ作成&候補者リストから削除 Creation of cargo handling worker data & deletion from candidate list
  def mk_cargo_worker(c_data, login_id, woker_info, competences, wk_type, wk_class, wk_index=0)
    #作業員の作業順 Work order of workers
    work_index = 0
    c_data[:workers].each_value{|workers|
      work_index += workers.count{|worker| worker[:login_id] == login_id}
    }
    #バスフラグチェック bus flag check
    bus_flg = 0
    if c_data[:machines].has_key?(wk_type) && c_data[:machines][wk_type].has_key?(wk_index)
      bus_flg = 1 if c_data[:machines][wk_type][wk_index][:m_type] == "bs"
    end
    c_worker = {
      :cargo_id => c_data["id"],
      :work_date => c_data["work_date"],
      :user_id => woker_info[:user_id],
      :login_id => login_id,
      :wk_type => wk_type,
      :wk_index => wk_index,
      :work_index => work_index,
      :bus_flg => bus_flg,
      :work_class => c_data["work_class"],
      :wk_class => wk_class,
      :s_time => nil,
      :e_time => nil,
      :work_time => 0,
      :orver_time => 0,
      :competence => competences[login_id],
      :lock_flg => 0,
    }

    #出勤時間＆終了時間 Starting time & finishing time
    s_time = WorkTimeAggregate.mk_time(c_data["work_date"],c_data["i_time"],Cargo::RegularITime) if c_data["i_time"].present?
    e_time = WorkTimeAggregate.mk_time(c_data["work_date"],c_data["e_time"],Cargo::RegularETime) if c_data["e_time"].present?

    #休暇チェック vacation check
    if woker_info[:vacation].present?
      base_no = woker_info[:vacation][:base_no]
      if [2,3,31,32,33,34,41,42].include?(base_no)
        vacation_day = woker_info[:vacation][:vacation_day]
        arriv_time   = woker_info[:vacation][:arriv_time]
        leav_time    = woker_info[:vacation][:leav_time]
        # 出勤時間 Working hours
        if arriv_time.present?
          arriv_time = WorkTimeAggregate.mk_time(vacation_day,arriv_time,arriv_time)
          s_time = arriv_time if s_time.blank? || (arriv_time > s_time)
        end
        # 終了時間 End time
        if leav_time.present?
          leav_time = WorkTimeAggregate.mk_time(vacation_day,leav_time,leav_time)
          e_time = leav_time if e_time.blank? || (leav_time < e_time)
        end
      end
    end
    c_worker[:s_time] = s_time if s_time.present?
    c_worker[:e_time] = e_time if e_time.present?


    #就業時間＆超過時間 Hours of Employment & Overtime
    if s_time.present? && e_time.present?
      #bus_flg補正 bus_flg correction
      if bus_flg == 1
        time_0700 = WorkTimeAggregate.mk_time(c_data["work_date"],"07:00","07:00")
        adj_s_time = c_worker[:s_time] - 30*60
        if adj_s_time <= time_0700
          adj_s_time = c_worker[:s_time]
          adj_e_time = c_worker[:e_time] + 30*60
        else
          adj_e_time = c_worker[:e_time]
        end
        c_worker[:s_time] = adj_s_time
        c_worker[:e_time] = adj_e_time
      end
      c_worker[:work_time], c_worker[:orver_time] = WorkTimeAggregate.calc_legal_work_time(c_data["work_date"],c_worker[:s_time],c_worker[:e_time],bus_flg)
    end

    woker_info[:cargo_ids] << c_data["id"]
    return c_worker
  end
  #
  #力量リストから削除して重複しないようにする Delete from the competency list to avoid duplication
  def delete_competences(woker_competences,login_id)
    woker_competences.each{|c_key,competences|
      if c_key == "ca"
        competences = delete_competences(competences,login_id)
      else
        competences.delete(login_id)
      end
    }
    return woker_competences
  end
  #該当の力量キーを特定 Identify the relevant competency key
  def get_competence_key(num_key,c_data,wk_index,wk_type,wk_class)
    machine_cd = ""; machine_type = "";
    ret_key = "none"
    if wk_index % 2 == 1
      if c_data[:machines].has_key?(wk_type) && c_data[:machines][wk_type].has_key?(wk_index)
        machine_cd = c_data[:machines][wk_type][wk_index][:machine_cd]
        machine_type = c_data[:machines][wk_type][wk_index][:m_type]
      end
    else
      if c_data[:machines].has_key?(wk_type) && c_data[:machines][wk_type].has_key?(wk_index-1)
        machine_cd = c_data[:machines][wk_type][(wk_index-1)][:machine_cd]
        machine_type = c_data[:machines][wk_type][(wk_index-1)][:m_type]
      elsif c_data[:machines].has_key?(wk_type) && c_data[:machines][wk_type].has_key?(wk_index)
        machine_cd = c_data[:machines][wk_type][wk_index][:machine_cd]
        machine_type = c_data[:machines][wk_type][wk_index][:m_type]
      end
    end
    case wk_class
    when "fm"
      if c_data["work_place"] =~ /7\-3/ && c_data["cargo_name"] =~ /石炭灰/
        ret_key = "fma"
      elsif c_data["work_place"] =~ /7\-5/ && c_data["cargo_name"] =~ /石炭灰/
        ret_key = "fmp"
      elsif c_data["work_class"] == 1
        ret_key = "fmm"
      elsif c_data["work_class"] == 2
        ret_key = "fmc"
      end
    when "dm"
      if c_data["work_place"] =~ /6\-1/ || c_data["work_place"] =~ /H\-1/
        ret_key = "sn"
      else
        ret_key = "dm"
      end
    when "wm" ; ret_key = "wwm"
    when "cr"
      if c_data["work_place"] =~ /3\-3/ || c_data["work_place"] =~ /3\-4/
        ret_key = "cr3"
      elsif c_data["work_place"] =~ /5\-1/
        ret_key = "cr5"
      elsif c_data["work_place"] =~ /6\-1/
        ret_key = "cr6"
      elsif c_data["work_place"] =~ /7\-1/ || c_data["work_place"] =~ /7\-2/
        ret_key = "cr7"
      elsif c_data["work_place"] =~ /H\-1/
        ret_key = "cru"
      elsif c_data["work_place"] =~ /O\-3/ || c_data["work_place"] =~ /O\-4/
        ret_key = "crg"
      elsif c_data["work_place"] =~ /7\-5/
        ret_key = "crp"
      elsif c_data["work_place"] =~ /H\-2/
        ret_key = "cre"
      elsif c_data["work_place"] =~ /7\-3/
        ret_key = "crs"
      end
    when "ld"
      if machine_type=="" || machine_type==wk_class
        if c_data["work_class"] == 1
          ret_key = "ldm"
        elsif c_data["work_class"] == 2
          ret_key = "ldc"
        end
      end
    when "bh"
      if machine_type=="" || machine_type==wk_class
        if c_data["work_class"] == 1
          if machine_cd =~ /ﾘｰｽﾊﾞ\d+/
            ret_key = "bhs"
          else
            ret_key = "bhh"
          end
        end
      end
    when "sl"
      if machine_type=="" || machine_type==wk_class
        if c_data["work_class"] == 1
          ret_key = "slm"
        elsif c_data["work_class"] == 2
          ret_key = "slc"
        end
      end
    when "bl"
      if machine_type=="" || machine_type==wk_class
        if c_data["work_class"] == 1 && c_data["work_place"] =~ /H\-3/
          ret_key = "blh"
        else
          ret_key = "bld"
        end
      end
    when "lf"
      if machine_type=="" || machine_type==wk_class
        if c_data["work_place"] =~ /物流ｾﾝﾀｰ/ || c_data["work_place"] =~ /物流センター/
          ret_key = "lfl"
        else
          ret_key = "lf"
        end
      end
    when "sc"
      if machine_type=="" || machine_type==wk_class
        if c_data["work_class"] == 1
          ret_key = "scm"
        elsif c_data["work_class"] == 2
          ret_key = "scc"
        end
      end
    when "tl"
      if machine_type=="" || machine_type=="lf"
        if c_data["work_class"] == 1
          ret_key = "tlm"
        elsif c_data["work_class"] == 2
          ret_key = "tlc"
        end
      end
    when "ot"
      if wk_type=="dr"
        if c_data["move_no"]=="HB000595" || c_data["move_no"]=="HB000596" || c_data["move_no"]=="HB000597" || c_data["move_no"]=="HB000599"
          ret_key = "cc"
        elsif c_data["cargo_name"] =~ /石炭/ && (c_data["work_place"] =~ /7\-1/ || c_data["work_place"] =~ /7\-2/ || c_data["work_place"] =~ /6\-1/ || c_data["work_place"] =~ /H\-1/)
          ret_key = "od"
        elsif c_data["work_place"] =~ /H\-1/ 
          ret_key = "ep"
        elsif c_data["work_place"] =~ /H/ 
          ret_key = "em"
        end
      elsif wk_type=="wk"
        if machine_cd =~ /ｽｲｰﾊﾟ/
          ret_key = "sw"
        elsif machine_cd =~ /散水/
          ret_key = "sp"
        elsif machine_cd =~ /掃除機/ || machine_cd =~ /三洋掃/
          ret_key = "clr"
        end
      end
    when "hd"
      if c_data["work_place"] =~ /3\-3/ || c_data["work_place"] =~ /3\-4/
        ret_key = "w3"
      elsif c_data["work_place"] =~ /5\-1/
        ret_key = "s5"
      elsif c_data["work_place"] =~ /7\-1/ || c_data["work_place"] =~ /7\-2/
        ret_key = "s7"
      end
    when "db" ; ret_key = "wgd"
    when "hs" ; ret_key = "wal"
    when "sn"
      if c_data["work_place"] =~ /6\-1/ || c_data["work_place"] =~ /H\-1/
        ret_key = "w6e"
      elsif c_data["work_place"] =~ /3\-3/ || c_data["work_place"] =~ /3\-4/ || c_data["work_place"] =~ /5\-1/ || c_data["work_place"] =~ /7\-1/ || c_data["work_place"] =~ /7\-2/
        ret_key = "wbg"
      elsif c_data["work_place"] =~ /物流ｾﾝﾀｰ/ || c_data["work_place"] =~ /物流センター/
        ret_key = "wlg"
      elsif (c_data["cargo_name"] =~ /ｺﾝﾃﾅ/ || c_data["cargo_name"] =~ /コンテナ/) && (c_data["work_place"] =~ /O\-3/ || c_data["work_place"] =~ /O\-4/)
        ret_key = "wsc"
      else
        ret_key = "wsm"
      end
    when "eg"
      if (c_data["cargo_name"] =~ /ｺﾝﾃﾅ/ || c_data["cargo_name"] =~ /コンテナ/) && (c_data["work_place"] =~ /O\-3/ || c_data["work_place"] =~ /O\-4/)
        ret_key = "wcc"
      else
        ret_key = "wc"
      end
    end
    return ret_key
  end
  #
  #===作業可能リストから作業者を選定
  #作業の残用時間が0の場合は累積残業時間が高い方から、
  #作業の残用時間が1以上の場合は累積残業時間が低い方から、
  #公休〇はできるだけ選ばない
  ##===Select a worker from the list of available workers 
  #If the remaining work time is 0, the cumulative overtime time is higher, 
  #If the remaining work time is 1 or more, the cumulative overtime time will be calculated from the lowest 
  #Do not choose public holidays as much as possible
  def choice_worker(random,c_data,woker_list,woker_infos)
    return nil if woker_list.blank?
    tmp_list = woker_list.keys
    return tmp_list[0] if tmp_list.size == 1
    return tmp_list[random.rand(tmp_list.size)] if tmp_list.size < 4
    if c_data["orver_time"] == 0
      tmp_list.sort_by!{|login_id| [(woker_infos[login_id][:vacation].blank? ? 0 : 1), woker_infos[login_id][:total_work_time][:orver_time].to_i * -1  ] }
    else
      tmp_list.sort_by!{|login_id| [(woker_infos[login_id][:vacation].blank? ? 0 : 1), woker_infos[login_id][:total_work_time][:orver_time].to_i] }
    end
    tmp_list = tmp_list[0..2]
    return tmp_list[random.rand(tmp_list.size)]
  end
  #
  #===試算評価 Estimate evaluation
  def do_assessment(cargos,wk_winfo)
    orver_times = []
    competences = []
    ret = {
      :shortage=>0,         #未配番人数（必要人数を満たしているか（配番人数-必要人数) Number of unassigned people (does the required number of people meet (number of assigned people - required number of people)
      :partners=>0,         #労協等の配番数 Number of labor unions, etc.
      :orver_time_var=>nil, #月残業時間の分散 Distribution of monthly overtime hours
      :orver_time_sd=>nil,  #月残業時間の標準偏差 Standard deviation of monthly overtime hours
      :competence_var=>nil, #力量の分散 Dispersion of competence
      :competence_sd=>nil,  #力量の標準偏差 standard deviation of competence
    }
    cargos.each{|cargo_id,c_data|
      worker_count = 0
      c_data[:workers].each{|type_class,workers|
        workers.each{|worker|
          if worker.present? && worker[:login_id].present?
            if worker[:user_id] == 0
              ret[:partners] += 1
            else
              tot = (wk_winfo.has_key?(worker[:login_id]) ? wk_winfo[worker[:login_id]][:total_work_time][:orver_time].to_i : 0)
              orver_times << (worker[:orver_time].to_i + tot )
              competences << worker[:competence]
            end
            worker_count += 1
          end
        }
      }
      if c_data[:need_count] > worker_count
        ret[:shortage] += (c_data[:need_count] - worker_count)
      end
    }
    #残業時間 overtime hours
    sum = orver_times.reduce(0){|sum,wi| sum + wi.to_i }
    mean = sum.to_f / (orver_times.size)
    ret[:orver_time_var] = (orver_times.present? ? orver_times.reduce(0){|sum,wi| sum + (wi.to_i - mean) ** 2 } / (orver_times.size) : 0)
    ret[:orver_time_sd] = Math.sqrt(ret[:orver_time_var])
    #力量 strength
    sum = competences.reduce(0){|sum,wi| sum + (wi.blank? ? 3 : wi) }
    mean = sum.to_f / (competences.size)
    ret[:competence_var] = (competences.present? ? competences.reduce(0){|sum,wi| sum + ((wi.blank? ? 3 : wi) - mean) ** 2 } / (competences.size) : 0)
    ret[:competence_sd] = Math.sqrt(ret[:competence_var])
    return ret
  end
  #
  #===評価もっともよい評価のシミュレーションを選択 Select the simulation with the best rating
  #時間外偏差の上位５つの中から最もうまく配番できたものを選択 Select the most successful number from among the top five after-hours deviations.
  def choice_assessment(sym_ret)
    tmp_list = sym_ret.keys
    tmp_list = tmp_list.sort_by{|sim_no| sym_ret[sim_no][:assessment][:orver_time_sd] }
    tmp_list = tmp_list[0..4]
    best_sym = tmp_list.sort_by{|sim_no| (sym_ret[sim_no][:assessment][:shortage]+sym_ret[sim_no][:assessment][:partners]) }
    return best_sym[0]
  end

  #
  #===配番データを結果にコピー Copy numbering data to results
  def do_copy_cargo(queue,work_date,uid)
    msg = mk_msg(queue)
    crf = %i[id cargo_id work_date login_id work_time orver_time s_time e_time work_index bus_flg]
    rcrf = %w[id result_cargo_id work_date login_id work_time orver_time s_time e_time work_index bus_flg cargo_worker_id]
    msg[:msg] = "配番予定データを配番確定データにコピー開始\n" ; msg.save!
    work_date = Date.strptime(work_date, "%Y%m%d")
    self.transaction do
      data_tbl = Cargo.where(["work_date=? And esta_flg<>'9'",work_date]).order(:desp_index).includes([:cargo_worker,:cargo_machine])
      data_tbl.each{|c|
        msg[:msg] = "#{c[:work_name]}(#{c[:move_no]})をコピー\n" ; msg.save!
        data = {}
        ResultCargo.attribute_names.each{|key|
          case key
          when "id","lock_version","deleted_at","deleted_uid","created_at","updated_at"
          when "created_uid","updated_uid" ; data[key] = uid
          when "cargo_id" ; data[key] = c[:id]
          when "conf_flg" ; data[key] = 0
          else data[key] = c[key]
          end
        }
        rcargo = self.find_by({:work_date=>data["work_date"],:cargo_id=>data["cargo_id"]})
        if rcargo.blank?
          rcargo = self.create(data)
        else
          rcargo.update(data)
        end
        c.cargo_worker.each{|c_worker|
          data = {}
          ResultCargoWorker.attribute_names.each{|key|
            case key
            when "id","lock_version","deleted_at","deleted_uid","created_at","updated_at"
            when "created_uid","updated_uid" ; data[key] = uid
            when "result_cargo_id" ; data[key] = rcargo[:id]
            when "cargo_worker_id" ; data[key] = c_worker[:id]
            when "base_no" ; data[key] = 1
            else data[key] = c_worker[key]
            end
          }
          lin = ResultCargoWorker.find_by({:result_cargo_id=>data["result_cargo_id"],:work_date=>data["work_date"],:wk_type=>data["wk_type"],:wk_index=>data["wk_index"]})
          if lin.blank?
            ResultCargoWorker.create(data)
          else
            lin.update(data)
          end

        }
        c.cargo_machine.each{|c_machine|
          data = {}
          ResultCargoMachine.attribute_names.each{|key|
            case key
            when "id","lock_version","deleted_at","deleted_uid","created_at","updated_at"
            when "created_uid","updated_uid" ; data[key] = uid
            when "result_cargo_id" ; data[key] = rcargo[:id]
            when "cargo_machine_id" ; data[key] = c_machine[:id]
            when "maintenanc_type","e_date","note" ; data[key] = nil
            else data[key] = c_machine[key]
            end
          }
          lin = ResultCargoMachine.find_by({:result_cargo_id=>data["result_cargo_id"],:work_date=>data["work_date"],:wk_type=>data["wk_type"],:wk_index=>data["wk_index"]})
          if lin.blank?
            ResultCargoMachine.create(data)
          else
            lin.update(data)
          end
        }
        #c[:lock_flg]=1
        c[:updated_uid] = uid
        c.save
      }
    end

    msg[:msg] = "配番予定データを配番確定データにコピー完了\n" ; msg.save!
  end


  # UAT213調査（元の関数
  # def do_copy_cargo(queue,work_date,uid)
  #   msg = mk_msg(queue)
  #   msg[:msg] = "配番予定データを配番確定データにコピー開始\n" ; msg.save!
  #   work_date = Date.strptime(work_date, "%Y%m%d")
  #   self.transaction do
  #     data_tbl = Cargo.where(["work_date=? And esta_flg<>'9'",work_date]).order(:desp_index).includes([:cargo_worker,:cargo_machine])
  #     data_tbl.each{|c|
  #       msg[:msg] = "#{c[:work_name]}(#{c[:move_no]})をコピー\n" ; msg.save!
  #       data = {}
  #       ResultCargo.attribute_names.each{|key|
  #         case key
  #         when "id","lock_version","deleted_at","deleted_uid","created_at","updated_at"
  #         when "created_uid","updated_uid" ; data[key] = uid
  #         when "cargo_id" ; data[key] = c[:id]
  #         when "conf_flg" ; data[key] = 0
  #         else data[key] = c[key]
  #         end
  #       }
  #       rcargo = self.find_by({:work_date=>data["work_date"],:cargo_id=>data["cargo_id"]})
  #       if rcargo.blank?
  #         rcargo = self.create(data)
  #       else
  #         rcargo.update(data)
  #       end
  #       c.cargo_worker.each{|c_worker|
  #         data = {}
  #         ResultCargoWorker.attribute_names.each{|key|
  #           case key
  #           when "id","lock_version","deleted_at","deleted_uid","created_at","updated_at"
  #           when "created_uid","updated_uid" ; data[key] = uid
  #           when "result_cargo_id" ; data[key] = rcargo[:id]
  #           when "cargo_worker_id" ; data[key] = c_worker[:id]
  #           when "base_no" ; data[key] = 1
  #           else data[key] = c_worker[key]
  #           end
  #         }
  #         lin = ResultCargoWorker.find_by({:result_cargo_id=>data["result_cargo_id"],:work_date=>data["work_date"],:wk_type=>data["wk_type"],:wk_index=>data["wk_index"]})
  #         if lin.blank?
  #           ResultCargoWorker.create(data)
  #         else
  #           lin.update(data)
  #         end
  #       }
  #       c.cargo_machine.each{|c_machine|
  #         data = {}
  #         ResultCargoMachine.attribute_names.each{|key|
  #           case key
  #           when "id","lock_version","deleted_at","deleted_uid","created_at","updated_at"
  #           when "created_uid","updated_uid" ; data[key] = uid
  #           when "result_cargo_id" ; data[key] = rcargo[:id]
  #           when "cargo_machine_id" ; data[key] = c_machine[:id]
  #           when "maintenanc_type","e_date","note" ; data[key] = nil
  #           else data[key] = c_machine[key]
  #           end
  #         }
  #         lin = ResultCargoMachine.find_by({:result_cargo_id=>data["result_cargo_id"],:work_date=>data["work_date"],:wk_type=>data["wk_type"],:wk_index=>data["wk_index"]})
  #         if lin.blank?
  #           ResultCargoMachine.create(data)
  #         else
  #           lin.update(data)
  #         end
  #       }
  #       #c[:lock_flg]=1
  #       c[:updated_uid] = uid
  #       c.save
  #     }
  #   end

  #   msg[:msg] = "配番予定データを配番確定データにコピー完了\n" ; msg.save!
  # end





end
