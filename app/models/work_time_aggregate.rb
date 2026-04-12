class WorkTimeAggregate < ApplicationRecord
  extend Common::Func
  default_scope {where(:deleted_at => nil)}

  #
  #===時間オブジェクト作成
  def self.mk_time(t_date,t_time,def_val)
    if t_time.blank?
      return Time.zone.parse(t_date.strftime("%Y/%m/%d #{def_val}"))
    elsif t_time.is_a?(String)
      return Time.zone.parse(t_date.strftime("%Y/%m/%d #{t_time}"))
    else
      return Time.zone.parse(t_date.strftime("%Y/%m/%d #{t_time.strftime("%H:%M")}"))
    end
  end

  # #===時間内判定
  def in_time?(t_time,start_time,end_time)
    inside = (start_time..end_time).cover?(t_time)
    inside
  end

  # #===シフトタイプ取得
  def self.shift_type(t_date,s_time)
    shift = "1直"
    if mk_time(t_date,"19:59","19:59") < s_time
      shift = "2直2" # 出勤時間 20:00～
    elsif mk_time(t_date,"18:59","18:59") < s_time
      shift = "2直1" # 出勤時間 19:00～
    end
    shift
  end

  #
  #===所定作業時間、残業時間算出 ... 基本7時間
  def self.calc_prescribed_work_time(t_date,s_time,e_time)
    #--変数初期化
    p_work_time = p_orver_time = p_early_time = 0
    s_time = mk_time(t_date,s_time,Cargo::RegularITime)
    e_time = mk_time(t_date,e_time,Cargo::RegularETime)
    e_time += 3600*24 if s_time > e_time
    p_work_time = ((e_time - s_time) / 60)
    case shift_type(t_date,s_time)
    when "1直"
      # 所定
      # 5. 終了が12:00以前の場合: 終了-出勤
      # 5‘. 開始が13:00以降の場合: 終了-出勤
      # 6. 上記以外: 終了-出勤-60分（12:00～60分昼食休憩）
      p_work_time -= 60 if e_time > mk_time(t_date,"12:00","12:00") && s_time < mk_time(t_date,"13:00","13:00")

      # 早出
      # ・出勤が08:00以前				08:00-出勤　（※PN年の場合でも計上
      time_0800 = mk_time(t_date,"08:00","08:00")
      p_early_time = [(time_0800 - s_time)/60, 0].max

      # 残業
      # 終了-16:00　（※AM年の場合でも計上、マイナスは0）
      p_orver_time = [(e_time - mk_time(t_date,"16:00","16:00"))/60, 0].max


    when "2直1","2直2"

      # 所定
      # 6. 上記以外: 終了-出勤-60分（12:00～60分昼食休憩）
      case shift_type(t_date,s_time)
      when "2直1"
        # 3. 出勤が19:00以降～終了23:30未満の場合: 終了-出勤（日付に注意）
        # 4. 出勤が19:00以降の場合: 終了-出勤-60分（23:00～60分夕食休憩、日付に注意）
        p_work_time -= 60 unless e_time < mk_time(t_date,"23:30","23:30")
      when "2直2"
        # 1. 出勤が20:00以降～終了00:00未満の場合: 終了-出勤（日付に注意）
        # 2. 出勤が20:00以降の場合: 終了-出勤-60分（00:00～60分夕食休憩、日付に注意）
        p_work_time -= 60 unless e_time < mk_time(t_date+1,"00:00","00:00")
      end

      # 早出
      # ・出勤が19:00以降～20:00＆終了が05:00以降 => 終了-05:00
      # ・出勤が19:00以降～20:00＆終了が05:00以前 => 0
      time_0500 = mk_time(t_date+1,"05:00","05:00")
      if e_time >= time_0500
        p_early_time = [(e_time - time_0500)/60, 0].max
      end

      # 残業
      case shift_type(t_date,s_time)
      when "2直1"
        # ・出勤が19:00以降				終了-02:00　（マイナスは0）
        p_orver_time = [(e_time - mk_time(t_date+1,"02:00","02:00"))/60, 0].max
      when "2直2"
        # ・出勤が20:00以降				終了-04:00　（マイナスは0）
        p_orver_time = [(e_time - mk_time(t_date+1,"04:00","04:00"))/60, 0].max
      end
    end

    return [p_work_time,p_orver_time,p_early_time]

  end

  #
  #===法定作業時間、残業時間算出 ... 基本8時間
  def self.calc_legal_work_time(t_date,s_time,e_time,bus_flg)
    work_time = orver_time = 0
    p_work_time = calc_prescribed_work_time(t_date,s_time,e_time)[0]
    s_time = mk_time(t_date,s_time,Cargo::RegularITime)
    e_time = mk_time(t_date,e_time,Cargo::RegularETime)
    e_time += 3600*24 if s_time > e_time
    work_time = p_work_time

    #法定実労
    case shift_type(t_date,s_time)
    when "1直"
      # 1直
      # ・出勤が19:00以前＆終了18:30未満				所定時間　-　30分		←手洗いのみ
      # ・出勤が19:00以前＆終了21:00未満				所定時間　-　60分		←手洗い＋30分休憩
      # ・出勤が19:00以前＆終了21:00以降				所定時間　-　90分		←手洗い＋30分休憩×２
      if e_time <= mk_time(t_date,"18:30","18:30")
        work_time -= 30
      elsif e_time < mk_time(t_date,"21:00","21:00")
        work_time -= 60
      elsif e_time >= mk_time(t_date,"21:00","21:00")
        work_time -= 90
      else
      end
    when "2直1"
      # 2直1
      # ・出勤が19:00以降～終了04:30未満				所定時間　-　30分		←手洗いのみ
      # ・出勤が19:00以降～				所定時間　-　60分		←手洗い＋30分休憩
      if e_time < mk_time(t_date+1,"04:30","04:30")
        work_time -= 30
      elsif e_time >= mk_time(t_date+1,"04:30","04:30")
        work_time -= 60
      else
      end

    when "2直2"
      # 2直2
      # ・出勤が20:00以降～終了05:00未満				所定時間　-　30分		←手洗いのみ
      # ・出勤が20:00以降～				所定時間　-　60分		←手洗い＋30分休憩
      if e_time < mk_time(t_date+1,"05:00","05:00")
        work_time -= 30
      elsif e_time >= mk_time(t_date+1,"05:00","05:00")
        work_time -= 60
      end
    end

    #バスフラグ
    # ・出勤時間に関わらずバスフラグが付いた場合				さらに-30分
    work_time -= 30 if bus_flg==1

    #法定残業
    # ・Max（法定実労-8時間、0）　←２直も同じ
    orver_time = [work_time - 8*60, 0].max

    return [work_time, orver_time]

  end

#出勤時間、終了時間の再計算（バスフラグに更新に伴う再計算に使用
# s_time -> 現在の出勤時間(YY:MM)
# e_time -> 現在の終業予定時間(YY:MM)
# cargo_i_time -> 配番作業の出勤時間(YY:MM)
# bus_flg -> 変更後のバスフラグ 0/1
def self.adjust_stime_etime_by_bus_flags(s_time,e_time,cargo_i_time,bus_flg)
  after_s_time = s_time
  after_e_time = e_time

  if bus_flg==1
    after_s_time -= (30*60)
    time_0700 = mk_time(s_time,"7:00","7:00")
    if after_s_time<time_0700
      after_s_time = s_time
      after_e_time += (30*60)
    end
  else
    time_0730 = mk_time(s_time,"7:30","7:30")
    if cargo_i_time>=time_0730
      after_s_time +=(30*60)
    else
      after_e_time -= (30*60)
    end
  end

  [after_s_time,after_e_time]  

end



  #
  #===月次集計
  def self.do_tally(wh)
    talls = {"W"=>{},"M"=>{}}
    #法定労働時間の算出
    lwk_days = wh[:e_date] - wh[:s_date] + 1
    lwk_weeks = (lwk_days.to_f / 7)
    lwk_time = (lwk_weeks * 40).round(1) * 60
    wh_cal = WhCalendar.find_by_term(wh[:s_date],wh[:e_date])

    sum_datas = WorkTimeSummary.where(:work_date=>[wh[:s_date]..wh[:e_date]])
    sum_datas.each{|sum|
      talls[sum[:aggr_flg]][sum[:t_cd]] ||= {
        :t_id => sum[:t_id],
        :work_time => 0,
        :orver_time => 0,
        :l_ot_wd => 0,
        :l_ot_45 => 0,
        :l_ot_80 => 0,
        :p_work_time => 0,
        :p_orver_time => 0,
        :p_early_time=> 0,
        :wd_base6_num => 0,
        :hd_base6_num => 0,
      }

      [:work_time,:orver_time,:p_work_time,:p_orver_time,:p_early_time].each{|key|
        talls[sum[:aggr_flg]][sum[:t_cd]][key] += sum[key].to_i
      }
      case wh_cal[sum[:work_date]][:wh_flg]
      when 0 #平日
        talls[sum[:aggr_flg]][sum[:t_cd]][:wd_base6_num] += 1 if sum[:base_no] == 6 && sum[:work_time] > 0
      when 1 #法定休日（日曜）
        if sum[:base_no] == 6 && sum[:work_time] > 0
          talls[sum[:aggr_flg]][sum[:t_cd]][:hd_base6_num] += 1
          talls[sum[:aggr_flg]][sum[:t_cd]][:l_ot_wd] += sum[:work_time].to_i
        end

      end
    }
    talls.each{|aggr_flg,sum_datas|
      sum_datas.each{|t_cd,sum_data|
        # ○法定(45)
        #   ① 法定(45)月間 ＝ ②総労働時間 - ③法定労働時間 - ④休日労働時間
        #     ② 総労働時間　＝ work_time_summaries.work_time の合計
        #     ③ 法定労働時間 ＝ 月日数 / 7 * 40
        #     ④ 休日労働時間 ＝ 日曜日の期間内就業時間合計
        #   ⑤ 法定(45)日々 ＝ work_time_summaries.over_time の合計を算出
        #   ⑥ 法定(45)（work_time_aggregates.l_ot_45）＝ [①法定(45)月間, ⑤法定(45)日々].max

        # ○法定(80)
        #   ⑦ 法定(80)（work_time_aggregates.l_ot_80）＝ ⑥法定(45) ＋ ⑧法定休日労働時間
        #     ⑧ 法定休日労働時間 ＝ 日曜日（work_time_summaries.work_date.wday = 0）の
        #         work_time_summaries.work_time の合計

        # -- 以下、UAT315の計算に基づく（ここから
          # 法定45　　 :l_ot_45->月間,:l_ot_45d->日々
          sum_data[:l_ot_45]  = [sum_data[:work_time] - lwk_time - sum_data[:l_ot_wd],0].max # マイナスは0補正する
          sum_data[:l_ot_45d] = sum_data[:orver_time]
          l_ot_45             = [sum_data[:l_ot_45],sum_data[:l_ot_45d]].max
          # 法定80
          sum_data[:l_ot_80]  = l_ot_45 + sum_data[:l_ot_wd]
        # -- （ここまで

        lin = self.unscoped.find_by({:t_year=>wh[:t_year],:t_month=>wh[:t_month],:aggr_flg=>aggr_flg,:t_cd=>t_cd})
        if lin.blank?
          lin = self.new({:t_year=>wh[:t_year],:t_month=>wh[:t_month],:aggr_flg=>aggr_flg,:t_cd=>t_cd,:created_uid=>"batch"})
        end
        [:t_id,:work_time,:orver_time,:l_ot_wd,:l_ot_45,:l_ot_45d,:l_ot_80,:p_work_time,:p_orver_time,:p_early_time,:wd_base6_num,:hd_base6_num].each{|key| lin[key] = sum_data[key]}
        lin[:updated_uid] = "batch"
        lin[:deleted_at] = nil
        lin.save
      }
    }

  end

  #=== 現業職労働時間・時間外管理表出力用の集計データを返す
  def self.get_for_work_time_summary_excel_data(t_year:,t_month:)
    def_data = {
      :login_id=>"", :name=>"",
      :p_over_time=>0, :p_early_time=>0, :p_sum_time=>0,
      :wd_base6_num=>0, :hd_base6_num=>0, :sum_base6_num=>0,
      :l_ot_45=>0, :l_ot_80=>0, :prescribed=>0,
      :f_agg_data=>false
    }

    # データ集計
    applicable = Applicable.get_applicable(1)
    branches = Branche.where(:applicable=>applicable).cargo_work_group.pluck(:cd,:name).to_h
    wokers = Woker.get_latest(Date.new(t_year,t_month,1)).includes(:user).cargo_woker
    login_ids = wokers.pluck(:login_id)
    work_time_agg = WorkTimeAggregate.where(:t_cd=>login_ids,:aggr_flg=>"W",:t_year=>t_year,:t_month=>t_month)
    work_time_agg = work_time_agg.pluck(:t_cd).zip(work_time_agg).to_h
    woker_group = {}
    wokers.each do |woker|
      user = woker.user
      next if user.blank?

      wt_agg = work_time_agg[woker[:login_id]]
      reg_data = def_data.dup
      reg_data[:login_id] = woker.login_id
      reg_data[:name] = user.name
      if wt_agg
        reg_data[:f_agg_data] = true
        reg_data[:p_over_time] = wt_agg[:p_orver_time]
        reg_data[:p_early_time] = wt_agg[:p_early_time]
        reg_data[:p_sum_time] = wt_agg[:p_orver_time] + wt_agg[:p_early_time]
        reg_data[:wd_base6_num] = wt_agg[:wd_base6_num]
        reg_data[:hd_base6_num] = wt_agg[:hd_base6_num]
        reg_data[:sum_base6_num] = wt_agg[:wd_base6_num] + wt_agg[:hd_base6_num]
        l_ot_45 = [wt_agg[:l_ot_45].to_i,wt_agg[:l_ot_45d].to_i].max
        reg_data[:l_ot_45] = l_ot_45==0 ? 0 : 1.0 * l_ot_45 /60
        reg_data[:l_ot_80] = wt_agg[:l_ot_80]==0 ? 0 : 1.0 * wt_agg[:l_ot_80] /60
        reg_data[:prescribed] = wt_agg[:p_orver_time]==0 ? 0 : 1.0 * wt_agg[:p_orver_time] /60
      end
      b_name = branches[woker[:branch_cd]]
      woker_group[b_name] ||= woker_group[b_name] = []
      woker_group[b_name] << reg_data
    end
    woker_group

  end

end
