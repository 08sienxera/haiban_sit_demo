class Formatter::ManagerWowExcelFormatter < Formatter::Formatter

  def initialize(t_date,*args)
    @tmp = args
    @t_date = t_date
    @wh, @branches, @wokers, @vacation_types, @vacations_on_date, @cargo_workers_on_date, @work_time_summaries, @work_time_aggr = args
    @branches = @branches.order(:cd=>:asc)
    @wokers = @wokers.order(:desp_index=>:asc)
    @sum_length = {
      :s => @wh[:s_date],
      :e => [@t_date-1,@wh[:s_date]].max
    }
    super()
    convert()
  end

  def convert()
    data = {
      :t_date=>@t_date,
      :file_name=>"",
      :sheet_count=>0,
      :sheets=>[],
      :tmp=>@tmp,
    }

    # シート 1-1～2-2 | Sheet 1-1~2-2
    @branches.each do |branch|
      sheet_data = sheet_template
      sheet_data[:sheet_name] = branch.name
      sheet_data[:sheet_title] = "#{branch.name.split("ｰ")[0]}課#{branch.name.split("ｰ")[1]}係"
      branch_member = @wokers.where(:branch_cd=>branch.cd)
      branch_member.each do |woker|
        row = []
        # 氏名 | full name								
        name = woker.user.name
        row << name

        #{対象日}分の勤怠	 | Attendance for {target day}								
        vac = @vacations_on_date.find_by_user_id(woker.user.id)

        v_name = vac.present? ? @vacation_types.find{|_,base_no,_| base_no==vac.base_no}[2] : ""
        row << v_name

        #{対象日-1}までの時間外	 | Out of hours until {target day-1}								
        wt_aggr = @work_time_aggr.find{|aggr| aggr[:t_cd]==woker.login_id} || {}
        orver_time = wt_aggr[:p_orver_time] + wt_aggr[:p_early_time]
        row << orver_time/60.0

        #{対象日}の見込時間外 | Outside the estimated hours on {target date}
        cws = @cargo_workers_on_date.where(:login_id=>woker.login_id)
        if cws.blank?
          row << 0.0
        else
          wk_sum = Batche::WorkTimeAggregate.mk_worker_sum({},cws,1)
          orver_time = wk_sum[:p_orver_time] + wk_sum[:p_early_time]
          row << orver_time/60.0
        end

        #{対象日}終了時点での見込時間外 | {Target date} Outside the estimated time at the end
        row << row[-2..].sum

        #{対象日}の作業内容 | Work details for {target date}
        if cws.present?
          #{対象日}の配番がある場合は　場所＋作業名＋本船/沿岸＋カテゴリ＋バス（作業員毎作業一覧出力の内容と同じ） | If there is a number assigned for {target date}, location + work name + ship/coast + category + bus (same as the content of the work list output for each worker)
          row << cws.first.cargo.work_name
        elsif vac.present?
          #{対象日}の勤怠が休みの場合は#{対象日}分の勤怠 | 
          row << v_name
        else
          row << ""
        end

        #{対象日}の備考 | Notes on {target date}	
        note = ""
        if vac.present? && VacationType.staggered.pluck(:base_no).include?(vac.base_no)
          note << v_name
          if vac.base_no==2 || vac.base_no==3 # 早遅or遅刻 | Early or late
            note << "(#{vac.arriv_time.to_s}～#{vac.leav_time.to_s})"
          end
        end
        row << note
        #{対象日}の早出、早退の場合は勤怠と各時間、看Ａ、看Ｐ、介Ａ、介Ｐ、年Ａ、年Ｐの場合は勤怠 | If you arrive early or leave early on {target day}, attendance and each hour; if you are in nursing A, nursing P, nursing A, nursing P, year A, or year P, attendance is attendance.

        # 公出　平日 | Public release weekdays
        row << wt_aggr[:wd_base6_num]

        # 公出　日曜 | Public release Sunday
        row << wt_aggr[:hd_base6_num]
        # 公出　合計 | Publication total
        row << (wt_aggr[:wd_base6_num] + wt_aggr[:hd_base6_num])
        sheet_data[:sheet_data] << row
        # sheet_data[:sheet_data] << row.map(&:to_s)
      end
      data[:sheets] << sheet_data

    end


    # シート 全体（所定） | Entire sheet (predetermined)
      sheet = sheet_template
      sheet[:sheet_name] = "全体（所定）"
      sheet[:sheet_title] = "所定時間外"

      # 対象作業員 --> 0
      #{対象日}まで　累計 --> 2
      #{対象日}まで　見込	--> 3
      #{対象日}まで　累計見込 --> 4
      # 公出　平日 --> 7
      # 公出　日曜 --> 8
      # 公出　合計 --> 9
      # Target workers --> 0 
      #Cumulative total up to {target date} --> 2 
      #Estimated until {target date} --> 3 
      #Estimated cumulative total until {target date} --> 4 
      # Public release weekdays --> 7 
      # Public release Sunday --> 8 
      # Publication total --> 9
      f = data[:sheets][0][:sheet_data]
      zip_list = f.zip(*data[:sheets][1..].map{|s| s[:sheet_data]})

      zip_list.each do |data_lines|
        row = []
        data_lines.each do |line|
          line ||= Array.new(10,"")
          row << line[0]
          row << line[2]
          row << line[3]
          row << line[4]
          row << line[7]
          row << line[8]
          row << line[9]
        end
        sheet[:sheet_data] << row
      end
      data[:sheets] << sheet

    # シート 全体（法定） | Whole sheet (statutory)
      sheet = sheet_template
      sheet[:sheet_name] = "全体（法定）"
      sheet[:sheet_title] = "法定時間外"

      #対象作業員
      #{対象日-1}まで　平日45月間
      #{対象日-1}まで　平日45日々
      #{対象日-1}まで　平日45採用
      #{対象日-1}まで　日曜80
      #Target workers 
      #Until {Target day-1} 45 weekdays 
      #Until {target day-1} 45 weekdays 
      #45 weekdays accepted until {target day-1} 
      #{Target day-1} until Sunday 80
      l_work_time_data = @branches.map do |branch|
        lines = []
        branch_member = @wokers.where(:branch_cd=>branch.cd)
        branch_member.each do |woker|
          row = []
          # 氏名 | full name
          name = woker.user.name
          #{対象日-1}までの時間外 | Out of hours until {target day-1}
          wt_aggr = @work_time_aggr.find{|aggr| aggr[:t_cd]==woker.login_id} || {}
          row << name
          l_ot_45m = wt_aggr[:l_ot_45]/60.0
          l_ot_45d = wt_aggr[:l_ot_45d]/60.0
          l_ot_45 = [l_ot_45m, l_ot_45d].max
          row << l_ot_45m
          row << l_ot_45d
          row << l_ot_45
          row << wt_aggr[:l_ot_80]/60.0
          lines << row
          # lines << row.map(&:to_s)
        end
        lines
      end
      f = l_work_time_data[0]
      zip_list = f.zip(*l_work_time_data[1..])
      zip_list.each do |data_lines|
        row = []
        data_lines.each do |line|
          line ||= Array.new(5,"")
          row.push(*line)
        end
        sheet[:sheet_data] << row
      end
      data[:sheets] << sheet


    data[:sheet_count] = data[:sheets].size
    store_data(data)
  end

  private   
  def sheet_template
    return {
      :sheet_name  => "",
      :sheet_title => "",
      :sheet_data  => [],
    }
  end


end
