# coding: utf-8
#--
#***************************************************************************
#*     ｼｽﾃﾑ名    ：
#*     ｻﾌﾞｼｽﾃﾑ名 ：    稼働時間集計バッチ
#*     ｺﾒﾝﾄ      ：
#*     作成      ：    2024/08/06 SEIKO
#*     変更	：
#***************************************************************************
#++
#=稼働時間集計バッチ
class Batche::WorkTimeAggregate < Batche::BatcheCommon

  #===集計開始
  # 作業時間の集計バッチにて出勤は時間の早い方、退勤は時間の遅い方を設定している。集計バッチにて出勤は作業Indexの若い方、退勤は作業Indexの最後の方を設定するように修正
  def self.do(symd=nil,eymd=nil)
    @ret = []
    @log = self.logger()
    log_info("batch start #{self.name}----")
    @myname = self.name.gsub("Batche::","")
    begin
      begin
        s_date = Date.strptime(symd, "%Y%m%d")
      rescue
        s_date = Date.today - 2
      end
      begin
        e_date = Date.strptime(eymd, "%Y%m%d")
      rescue
        e_date = Date.today + 2
      end
      log_info("集計期間：#{s_date.strftime("%Y/%m/%d")} ～ #{e_date.strftime("%Y/%m/%d")}")
      if s_date > e_date
        log_error("期間指定不良")
        return @ret
      end

      log_debug("作業時間＆残業時間サマリー作成")
      worker_sum = {}
      machine_sum = {}
      work_date = s_date
      while work_date <= e_date
        log_debug("--#{work_date.strftime("%Y/%m/%d")}")
        worker_sum[work_date] = {}
        machine_sum[work_date] = {}
        rcs = ResultCargo.where(:work_date=>work_date,:conf_flg=>1)
        if rcs.blank?
          cs = Cargo.where(:work_date=>work_date,:conf_flg=>1)
          log_debug("----予定から生成")
          workers = cs.map{|c| c.cargo_worker.pluck(:login_id)}.flatten.uniq
          workers.each{|login_id|
            cws = CargoWorker.where(:login_id=>login_id,:work_date=>work_date)
            worker_sum[work_date][login_id] = mk_worker_sum(worker_sum[work_date],cws,1) if cws.present?
          }
          tbl = CargoMachine.where(:work_date=>work_date)
          tbl.each{|lin|
            machine_sum[work_date][lin[:machine_cd]] = mk_machine_sum(machine_sum[work_date],lin,1)
          }
        else
          log_debug("----結果から生成")
          workers = rcs.map{|rc| rc.result_cargo_worker.pluck(:login_id)}.flatten.uniq
          workers.each{|login_id|
            rcws = ResultCargoWorker.where(:login_id=>login_id,:work_date=>work_date)
            worker_sum[work_date][login_id] = mk_worker_sum(worker_sum[work_date],rcws,1) if rcws.present?
          }
          rcs.each{|rc|
            rc.result_cargo_machine.each{|lin|
              machine_sum[work_date][lin[:machine_cd]] = mk_machine_sum(machine_sum[work_date],lin,1)
            }
          }
        end

        #休暇情報の補完
        vs = Vacation.where("vacation_day=?",work_date)
        # UAT-276　不具合対応
        # vs = Vacation.where(["vacation_day=? or (origin_date=? and base_no='7') ",work_date,work_date])
        vs.each{|lin|
          base_no = (lin[:vacation_day] == work_date ? lin[:base_no] : 6)
          unless worker_sum[work_date].has_key?(lin[:login_id])
            worker_sum[work_date][lin[:login_id]] = {
              :t_id => lin[:user_id],
              :s_time => nil,
              :e_time => nil,
              :bus_flg => 0,
              :work_class => nil,
              :base_no => base_no,
              :work_time => 0,
              :orver_time => 0,
              :p_work_time => 0,
              :p_orver_time => 0,
              :p_early_time => 0,
              :data_root => 0,
            }
          else
            if worker_sum[work_date][lin[:login_id]][:base_no] != 6
              worker_sum[work_date][lin[:login_id]][:base_no] = base_no
            end
          end
        }
        work_date += 1
      end
      WorkTimeSummary.transaction do
        worker_sum.each{|work_date,worker_sums|
          worker_sums.each{|login_id,wk_data|
            WorkTimeSummary.create_by_batch("W",work_date,login_id,wk_data)
          }
        }
        machine_sum.each{|work_date,machine_sums|
          machine_sums.each{|machine_cd,wk_data|
            WorkTimeSummary.create_by_batch("M",work_date,machine_cd,wk_data)
          }
        }
        log_debug("月次データ集計")
        whs = WhSummary.where([" ? between s_date and e_date or ? between s_date and e_date ",s_date,e_date])
        whs.each{|wh|
          WorkTimeAggregate.do_tally(wh)
        }
        log_debug("過去データ削除")
        WorkTimeSummary.unscoped.where(["work_date < ?",Date.today.years_ago(3)]).destroy_all
      end
    # rescue
    #   log_error($!)
    #   log_error("---backtrace---")
    #   log_error($!.backtrace.join("\n"))
    #   #ExceptionNotifier::Notifier.exception_notification(Rails.env,$!).deliver_now
    end
    log_info("batch End #{self.name}----")  
    return @ret
  end
  #
  #===作業員の作業時間＆残業時間サマリーデータ作成
  def self.mk_worker_sum(worker_sum_by_date,lin,data_root)

    work_date = lin.first[:work_date]
    lin_sort_by_work_index = lin.order(:work_index)
    # 出勤時間、退勤時間
    s_time_all_nil = lin.all?{|l| l[:s_time].nil?}
    e_time_all_nil = lin.all?{|l| l[:e_time].nil?}
    time_1600 = WorkTimeAggregate.mk_time(work_date,"16:00","16:00")
    # UAT301 作業Indexではなく、s_timeは一番早い時間、e_timeは一番遅い時間を使用
    s_time = s_time_all_nil ? nil : lin_sort_by_work_index.where.not(s_time: nil).map{|l| WorkTimeAggregate.mk_time(l[:work_date],l[:s_time],l[:s_time])}.min
    e_time = e_time_all_nil ? time_1600 : lin_sort_by_work_index.where.not(e_time: nil).map{|l| WorkTimeAggregate.mk_time(l[:work_date],l[:e_time],l[:e_time])}.max

    wk_data = {
      :t_id => lin.first[:user_id],
      :s_time => s_time,
      :e_time => e_time,
      :bus_flg => lin.any?{|l| l[:bus_flg] == 1} ? 1 : 0,
      :work_class => lin_sort_by_work_index.first[:work_class],
      :base_no => 1,
      :work_time => 0,
      :orver_time => 0,
      :p_work_time => 0,
      :p_orver_time => 0,
      :p_early_time => 0,
      :data_root => data_root
    }

    if s_time.present? && e_time.present?
      s_time_HHMM = s_time.strftime("%H:%M")
      e_time_HHMM = e_time.strftime("%H:%M")
      wk_data[:p_work_time] , wk_data[:p_orver_time] , wk_data[:p_early_time] = WorkTimeAggregate.calc_prescribed_work_time(work_date,s_time_HHMM,e_time_HHMM)
      wk_data[:work_time] , wk_data[:orver_time] = WorkTimeAggregate.calc_legal_work_time(work_date,s_time_HHMM,e_time_HHMM,wk_data[:bus_flg])
    end
    wk_data
  end

  #
  #===機械の作業時間＆残業時間サマリーデータ作成
  def self.mk_machine_sum(machine_sum_by_date,lin,data_root)
    unless machine_sum_by_date.has_key?(lin[:machine_cd])
      s_time = lin[:s_time].present? ? WorkTimeAggregate.mk_time(lin[:work_date],lin[:s_time],lin[:s_time]) : nil
      e_time = lin[:e_time].present? ? WorkTimeAggregate.mk_time(lin[:work_date],lin[:e_time],lin[:e_time]) : nil
      e_time = WorkTimeAggregate.mk_time(lin[:work_date],"16:00","16:00") if e_time.blank?
      e_time += 3600*24 if s_time.present? && e_time.present? && s_time > e_time

      wk_data = {
        :t_id => lin[:machine_id],
        :s_time => s_time,
        :e_time => e_time,
        :bus_flg => 0,
        :work_class => lin[:work_class],
        :work_time => 0,
        :orver_time => 0,
        :p_work_time => 0,
        :p_orver_time => 0,
        :p_early_time => 0,
        :data_root => data_root,
      }

      if s_time.present? && e_time.present?
        wk_data[:work_time] , wk_data[:orver_time], wk_data[:p_early_time] = WorkTimeAggregate.calc_prescribed_work_time(lin[:work_date],lin[:s_time],lin[:e_time])
        wk_data[:p_work_time] = wk_data[:work_time]
        wk_data[:p_orver_time] = wk_data[:orver_time] + wk_data[:p_early_time]
      end
      return wk_data
    else
      wk_data = machine_sum_by_date[lin[:machine_cd]]
      is_change = false
      s_time = lin[:s_time].present? ? WorkTimeAggregate.mk_time(lin[:work_date],lin[:s_time],lin[:s_time]) : nil
      e_time = lin[:e_time].present? ? WorkTimeAggregate.mk_time(lin[:work_date],lin[:e_time],lin[:e_time]) : nil
      e_time = WorkTimeAggregate.mk_time(lin[:work_date],"16:00","16:00") if e_time.blank?
      e_time += 3600*24 if s_time.present? && e_time.present? && s_time > e_time

      if wk_data[:s_time].present? && s_time.present? && wk_data[:s_time] > s_time
        wk_data[:s_time] = s_time ; is_change = true
      end
      if wk_data[:e_time].present? && e_time.present? && wk_data[:e_time] < e_time
        wk_data[:e_time] = e_time ; is_change = true
      end
      if wk_data[:work_class] != 3 && wk_data[:work_class] != lin[:work_class]
        wk_data[:work_class] = 3
      end
      if is_change && s_time.present? && e_time.present?
        wk_data[:work_time] , wk_data[:orver_time], wk_data[:p_early_time] = WorkTimeAggregate.calc_prescribed_work_time(lin[:work_date],wk_data[:s_time],wk_data[:e_time])
        wk_data[:p_work_time] = wk_data[:work_time]
        wk_data[:p_orver_time] = wk_data[:orver_time] + wk_data[:p_early_time]
      end

      return wk_data
    end
  end

end
