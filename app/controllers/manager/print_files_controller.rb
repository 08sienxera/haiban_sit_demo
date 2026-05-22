class Manager::PrintFilesController < Manager::HomeController
  before_action :set_groval_variables

  #=== 随時帳票出力
  # リクエストパラメータ
  # mord : 出力する帳票を指定
  # t_s_date : 集計期間の開始日
  # t_e_date : 集計期間の終了日
  # t_date : 対象日
  # 
  # パラメータ例1）t_s_date"=>"2024/09/01", "t_e_date"=>"2024/09/30", "mord"=>"MONTHLY_CARGO_WORK_RESULT.PDF"
  # パラメータ例2）"t_date"=>"2024/10/10", "mord"=>"CARGO_REQUEST_HEAD_COUNT.PDF",
  #=== Ongoing Report Output
  # Request Parameters
  # mord: Specifies the report to output
  # t_s_date: Start date of the aggregation period
  # t_e_date: End date of the aggregation period
  # t_date: Target date
  #
  # Parameter Example 1) "t_s_date"=>"2024/09/01", "t_e_date"=>"2024/09/30", "mord"=>"MONTHLY_CARGO_WORK_RESULT.PDF"
  # Parameter Example 2) "t_date"=>"2024/10/10", "mord"=>"CARGO_REQUEST_HEAD_COUNT.PDF",
  def create
    case params[:mord]
      when "hogehoge"
        #hogehogeはManager::HomeController.menuの  javascript:dlFile(document.f1,'hoge'); のhogeで設定
        #該当する出力ファイルを生成し、send_fileする
        #hogehoge is set in Manager::HomeController.menu's javascript:dlFile(document.f1,'hoge'); using hoge.
        #Generate the corresponding output file and send_file
      when "SAGYO_REQUEST.PDF"  #作業依頼書 #Work request form
        t_date = Date.strptime(params[:t_date],"%Y/%m/%d")
        condition1 = CargoRequest.where(:work_date=>t_date,:work_class=>1).order({:work_place=>:asc,:move_no=>:asc,:work_no=>:asc,:serial_no=>:asc})
        sql = Arel.sql("CAST(SUBSTRING(move_no2,3) AS UNSIGNED) ASC")
        condition2 = CargoRequest.where(:work_date=>t_date,:work_class=>2).order(sql)
        condition3 = CargoRequest.where(:work_date=>t_date,:work_class=>3).order({:work_place=>:asc,:move_no=>:asc,:work_no=>:asc,:serial_no=>:asc})
        t_date_requests = condition1+condition2+condition3
    
        cargo_requests = {}
        t_date_requests.each do |req|
          key = "#{req[:department_cd]}_#{req[:work_class]}"
          cargo_requests[key] ||= []
          cargo_requests[key] << req
        end
        pdf = Pdf::SagyoRequestsPdf.new("SagyoRequestsPdf#{request.session_options[:id]}",{:page_layout => :landscape})
        pdf.create(t_date,cargo_requests)
        output = pdf.fin()
        send_file(output,:filename=>"作業依頼書_#{t_date.strftime("%Y%m%d")}.pdf",:status=>200) 

      when "CARGO_REQUEST_HEAD_COUNT.PDF"  #必要人数表（調整用 #Required number of people (for adjustment)
        t_date = Date.strptime(params[:t_date],"%Y/%m/%d")
        # 指定日の作業依頼を指定順に抽出 # Extract work requests for the specified date in the specified order.
        condition1 = CargoRequest.where(:work_date=>t_date,:work_class=>1).order({:work_place=>:asc,:move_no=>:asc,:work_no=>:asc,:serial_no=>:asc})
        sql = Arel.sql("CAST(SUBSTRING(move_no2,3) AS UNSIGNED) ASC")
        condition2 = CargoRequest.where(:work_date=>t_date,:work_class=>2).order(sql)
        condition3 = CargoRequest.where(:work_date=>t_date,:work_class=>3).order({:work_place=>:asc,:move_no=>:asc,:work_no=>:asc,:serial_no=>:asc})
        t_date_requests = condition1+condition2+condition3
    
        vac_table_data = Vacation.get_wokers_vacation_totalling_list(t_date)
        pdf = Pdf::CargoRequestHeadCountPdf.new("CargoRequestHeadCountPdf",{:page_size => 'A3',:page_layout => :landscape})
        pdf.create(t_date,t_date_requests,vac_table_data)
        output = pdf.fin()
        send_file(output,:filename=>"必要人数表(調整用)_#{t_date.strftime("%Y%m%d")}.pdf",:status=>200) 
        
      when "CARGO_HEAD_COUNT.PDF"  #配番人数表 # Number of people assigned
        t_date = Date.strptime(params[:t_date],"%Y/%m/%d")
        condition1 = Cargo.where(:work_date=>t_date,:work_class=>1).order({:work_place=>:asc,:move_no=>:asc,:work_no=>:asc,:serial_no=>:asc})
        sql = Arel.sql("CAST(SUBSTRING(move_no,3) AS UNSIGNED) ASC")
        condition2 = Cargo.where(:work_date=>t_date,:work_class=>2).order(sql)
        condition3 = Cargo.where(:work_date=>t_date,:work_class=>3).order({:work_place=>:asc,:move_no=>:asc,:work_no=>:asc,:serial_no=>:asc})
        t_date_cargos = condition1+condition2+condition3
        
        vac_table_data = Vacation.get_wokers_vacation_totalling_list(t_date)
        pdf = Pdf::CargoHeadCountPdf.new("CargoHeadCountPdf",{:page_size => 'A3',:page_layout => :landscape})
        pdf.create(t_date,t_date_cargos,vac_table_data)
        output = pdf.fin()
        send_file(output,:filename=>"配番人数表_#{t_date.strftime("%Y%m%d")}.pdf",:status=>200) 
      when "WOW.PDF"
        req_user = User.find(get_uval(:id))
        t_branch_cd = nil
        if req_user[:auth_flg]==3
          t_branch_cd = req_user[:branch_cd]
        end
        file_name = "勤怠・時間外管理表"
        t_date = Date.strptime(params[:t_date],"%Y/%m/%d")
        t_tarm = get_month(t_date) #集計月次範囲 #Monthly aggregation range
        excel_path = Woker.mk_wow_excel(file_name,t_date,t_tarm,t_branch_cd)
        send_file(excel_path,:filename=>"#{file_name}.xls",:status=>200) 
        return
      when "TIME_SHEET.PDF"  #出勤時間表 #Work schedule
        grouping_woker_data = {}; rel_data = {}
        #== 対象グループ  Target Group
        branches = Branche.cargo_work_group.pluck(:cd,:name)
        branches.each do |bch|
          grouping_woker_data[bch[0]] = [] unless grouping_woker_data[bch[0]]
        end
        branches = branches.to_h
        
        #== 対象作業員 Target workers
        wokers = Woker.get_latest(@t_date).where(:branch_cd=>branches.map{|(b_cd,_)| b_cd}).includes(:user)
        wokers.each do |woker|
          grouping_woker_data[woker[:branch_cd]] << woker[:login_id]
        end
        wokers = wokers.pluck(:login_id).zip(wokers).to_h

        #== 当日 荷物作業員 On the day of the event: Luggage handlers

        cargo_wokers = CargoWorker.where(work_date:@t_date).joins(:cargo).includes(:cargo).order(:login_id=>:asc,:wk_index=>:asc).group_by{|cw| cw[:login_id]}
        
        #== 当日　休暇データ Day of leave data
        vacations = Vacation.where(vacation_day:@t_date)
        vacations = vacations.pluck(:login_id).zip(vacations).to_h if vacations

        #== 休暇グループ　ID、名称ペア Vacation group ID, name pair
        vacation_types = VacationType.all.pluck(:id,:time_sheet_name).to_h
        
        rel_data[:branches] = branches
        rel_data[:wokers] = wokers
        rel_data[:cargo_wokers] = cargo_wokers
        rel_data[:vacations] = vacations
        rel_data[:vacation_types] = vacation_types

        #== PDF作成クラス =*=*=*=*=*=* #== PDF creation class =*=*=*=*=*=*=*
        pdf = Pdf::TimeSheetPdf.new("CargoRequestsPdf",{:page_size => 'A3',:page_layout => :landscape})
        pdf.create(@t_date,grouping_woker_data,rel_data)
        output = pdf.fin()
        send_file(output,:filename=>"出勤時間表_#{@t_date.strftime("%Y%m%d")}.pdf",:status=>200) 

        # =*=*=*=*=*=*=*=*=*=*=*=*=*=*
      when "WORK_DAILY_SHEET.PDF"  #出勤日報 残業届 #Work attendance report Overtime request
        grouping_woker_data = {}; rel_data = {}
        #== 対象グループ Target group
        branches = Branche.cargo_work_group.pluck(:cd,:name)
        branches.each do |cd,_|
          grouping_woker_data[cd] ||= []
        end
        branches = branches.to_h
        
        #== 対象作業員 Target workers
        t_date = Date.strptime(params[:t_date],"%Y/%m/%d")
        wokers = Woker.get_latest(t_date).where(:branch_cd=>branches.keys).where.not(:login_id=>Woker::WithoutMembers).includes(:user)
        wokers.each do |woker|
          branch_cd,login_id = woker.values_at(:branch_cd,:login_id)
          grouping_woker_data[branch_cd] << login_id
        end
        wokers = wokers.pluck(:login_id).zip(wokers).to_h

        #== 当日　荷物作業員 On the day of the event: Luggage handlers
        cargo_wokers = CargoWorker.where(work_date:@t_date).includes(:cargo).order(:login_id=>:asc,:wk_index=>:asc).filter{|cw| cw.cargo.present?}
        # cargo_wokers = CargoWorker.where(work_date:@t_date).includes(:cargo).order(:login_id=>:asc,:wk_index=>:asc)
        tmp_hash = {}
        cargo_wokers.each do |cw|
          tmp_hash[cw[:login_id]] ||= []
          tmp_hash[cw[:login_id]] << cw
        end
        cargo_wokers = tmp_hash

        #== 当日　休暇データ Day of leave data
        vacations = Vacation.where(vacation_day:@t_date,:deleted_uid=>nil,:deleted_at=>nil)
        vacations = vacations.pluck(:login_id).zip(vacations).to_h if vacations

        #== 休暇グループ　ID、名称ペア Vacation group ID, name pair
        vacation_types = VacationType.all.pluck(:id,:time_sheet_name).to_h
        
        rel_data[:branches] = branches
        rel_data[:wokers] = wokers
        rel_data[:cargo_wokers] = cargo_wokers
        rel_data[:vacations] = vacations
        rel_data[:vacation_types] = vacation_types
        
        #== PDF作成クラス =*=*=*=*=*=* #== PDF creation class =*=*=*=*=*=*=*
        pdf = Pdf::WorkDailySheetPdf.new("CargoRequestsPdf",{:page_size => 'A4', :top_margin => 20})
        pdf.create(@t_date,grouping_woker_data,rel_data)

        output = pdf.fin()
        send_file(output,:filename=>"出勤日報・残業届_#{@t_date.strftime("%Y%m%d")}.pdf",:status=>200) 

      when 'CARGO_SCHEDULE.PDF' #配番表(予定) #Assignment schedule (tentative)
        #== 当日配番データ Daily assignment data
        cargos = Cargo.includes(:cargo_machine=>:machine,:cargo_worker=>:woker).where(:work_date=>@t_date).order(:desp_index)
        cargos.each{|cargo| cargo.update_np_count}
        #== cargo_workerの作業順 最小リスト Minimum list of cargo_worker work order
        cw_first_id = build_cw_first_id_list(@t_date,CargoWorker)
        #== 配番割当　作業員、機械データ Assignment of worker and machine data
        assigned_data = build_assign_data(@t_date,cargos)
        #== 対象日の休暇データ Vacation data for the target date
        vacation_wokers = build_vacation_wokers_list(CargoWorker,@t_date)
        #== PDF作成クラス =*=*=*=*=*=* PDF creation class =*=*=*=*=*=*
        pdf = Pdf::CargoPdf.new("CargoSchedulePdf",{:page_size => 'A3', :page_layout => :landscape, :top_margin => 20},name:"配番表(予定)_#{@t_date.strftime("%Y%m%d")}",title:"荷役作業予定　及び　配番表")
        pdf.create(@t_date,cargos,assigned_data,vacation_wokers)
        output = pdf.fin()
        send_file(output,:filename=>"#{pdf.name}.pdf",:status=>200) 
      when 'CARGO_RESULT.PDF' #配番表(実績) # Assignment list (actual results)
        #== 当日配番データ Daily assignment data
        cargos = ResultCargo.includes(:result_cargo_machine=>:machine,:result_cargo_worker=>:woker).where(:work_date=>@t_date).order(:desp_index)
        cargos.each{|cargo| cargo.update_np_count}
        #== cargo_workerの作業順 最小リスト Minimum list of cargo_worker work order
        cw_first_id = build_cw_first_id_list(@t_date,ResultCargoWorker)
        #== 配番割当　作業員、機械データ Assignment of worker and machine data
        assigned_data = build_assign_result_data(@t_date,cargos)
        # return
        #== 対象日の休暇データ Vacation data for the target date
        vacation_wokers = build_vacation_wokers_list(ResultCargoWorker,@t_date)
        #== PDF作成クラス =*=*=*=*=*=* PDF creation class =*=*=*=*=*=*
        pdf = Pdf::CargoPdf.new("CargoResultPdf",{:page_size => 'A3', :page_layout => :landscape, :top_margin => 20},name:"配番表(実績)_#{@t_date.strftime("%Y%m%d")}",title:"荷役作業　及び　配番表")
        pdf.create(@t_date,cargos,assigned_data,vacation_wokers)
        output = pdf.fin()
        send_file(output,:filename=>"#{pdf.name}.pdf",:status=>200) 
      when "CARGO_WORKER_SCHEDULE.CSV"
        generate_cargo_work_pdf(params[:mord], @t_date)
      when "CARGO_WORKER_RESULT.CSV"
        generate_cargo_work_pdf(params[:mord], nil, params)
      when "TIME_CARD.CSV"  #タイムカードデータ(既存システム連携データ) #Time card data (data linked to existing system)
        require 'kconv'
        t_date = Date.strptime(params[:t_date], "%Y/%m/%d")
        output = Woker.get_time_card_data(params[:t_date])
        send_data(
          output.join("").kconv(Encoding::SJIS,Kconv::UTF8),
          :type        => csv_content_type(),
          :filename    => "作業予定データ_#{t_date.strftime("%Y%m%d")}.csv",
          :disposition => 'attachment'
        )
          
      when "SAGYO_HAIBAN.CSV"  #荷役実績(既存連携データ)  Cargo handling performance (existing linked data)
        require 'kconv'
        t_date = Date.strptime(params[:t_date],"%Y/%m/%d")
        t_date_str = t_date.strftime("%Y%m%d")
        output = ResultCargo.get_csv_data(t_date)
        send_data(output.join("").kconv(Encoding::CP932,Kconv::UTF8), :type => csv_content_type(),
          :filename => "SAGYO_HAIBAN_#{t_date_str}.CSV",:disposition=>'attachment')
      when "LUNCH_SUMMARY.EXCEL"
        s_date,e_date = get_both_date(params)
        redirect_to(:controller=>:lunch_summary,:action=>:excel_output,:s_date=>s_date,:e_date=>e_date)
      when "TAX_FREE_MACHINES_PDF"
        # データ集計 Data aggregation
        s_date,e_date = get_both_date(params)
        
        lo_machines = Machine.where(:light_oil=>1).pluck(:id,:name).to_h
        result_cargo_machines = ResultCargoMachine.
          where(:machine_id=>lo_machines.keys, :work_date=>s_date..e_date).
          where.not(:work_time=>nil).
          order(:work_date=>:asc).group_by(&:machine_id)
        result_cargo_machines = result_cargo_machines.
          transform_values{|list| list.map{|rcm| [rcm[:work_date], rcm[:work_time]]}.to_h}.
          transform_keys{|machine_cd| lo_machines[machine_cd]}
        calendar = WhCalendar.where(:t_date=>s_date..e_date).pluck(:t_date,:wh_flg).to_h

        # PDF作成クラス PDF creation class
        name_prefix = "TaxFreeMachines"
        main_title = "免税軽油稼働実績表"
        sub_title = "#{s_date.strftime('%Y 年 %m 月 %d 日')} ～ #{e_date.strftime('%Y 年 %m 月 %d 日')}"
        pdf = Pdf::TaxFreeMachinesPdf.new(name_prefix, { page_size: 'A4', page_layout: :landscape, top_margin: 35 }, name: "#{main_title}_#{(t_date || Time.now).strftime('%Y%m%d')}", title: main_title, sub_title: sub_title)
        pdf.create(lo_machines,result_cargo_machines,calendar)
        output = pdf.fin
        send_file(output, filename: "#{pdf.name}.pdf", status: 200)
      when "DAILY_CARGO_WORK_RESULT.PDF"
        # データ集計 Data aggregation
        s_date,e_date = get_both_date(params)
        daily_work_data = ResultCargo.get_daily_work_data(s_date..e_date)
        # PDF作成クラス PDF creation class
        name_prefix = "DailyCargoWorkResult"
        main_title = "日別荷役作業実績表"
        sub_title = "#{s_date.strftime('%y 年 %m 月 %d 日')} ～ #{e_date.strftime('%y 年 %m 月 %d 日')}"
        pdf = Pdf::DailyCargoWorkResultPdf.new(name_prefix, { page_size: 'A4', page_layout: :landscape, top_margin: 35 }, name: "#{main_title}_#{(t_date || Time.now).strftime('%Y%m%d')}", title: main_title, sub_title: sub_title)
        pdf.create(daily_work_data)
        output = pdf.fin
        send_file(output, filename: "#{pdf.name}.pdf", status: 200)
        
      when "MONTHLY_CARGO_WORK_RESULT.PDF"
        # データ集計 Data aggregation
        s_date,e_date = get_both_date(params)
        monthly_work_data = ResultCargo.get_monthly_work_data(s_date..e_date)
        
        # PDF作成クラス PDF creation class
        name_prefix = "MonthlyCargoWorkResult"
        main_title = "荷役作業実績表"
        sub_title = "#{s_date.strftime('%y 年 %m 月 %d 日')} ～ #{e_date.strftime('%y 年 %m 月 %d 日')}　　延べ人数(台数)"
        pdf = Pdf::MonthlyCargoWorkResultPdf.new(name_prefix, { page_size: 'A4', page_layout: :landscape, top_margin: 35 }, name: "#{main_title}_#{(t_date || Time.now).strftime('%Y%m%d')}", title: main_title, sub_title: sub_title)
        pdf.create(monthly_work_data)
        output = pdf.fin
        send_file(output, filename: "#{pdf.name}.pdf", status: 200)
      when "WORK_TIME_SUMMARY.EXCEL"
        t_yyyy,t_mm = params.values_at(:m_yyyy,:m_mm)
        t_branches = Branche.where(:cd=>Branche::WorkerBranchCd).pluck(:cd,:name)
        woker_group = WorkTimeAggregate.get_for_work_time_summary_excel_data(:t_year=>t_yyyy.to_i,:t_month=>t_mm.to_i)
        data = {}
        data[:t_year] = t_yyyy.to_i
        data[:t_month] = t_mm.to_i
        data[:group] = t_branches.map{|cd,name|
          aggr_data = woker_group[name] || []
          [name,aggr_data]
        }.to_h
        # EXCEL作成クラス Excel creation class
        name = "現業職労働時間・時間外管理表"
        excel_builder = Excel::WorkTimeSummaryExcel.new(name)
        excel_builder.create(data[:group])

        output = excel_builder.fin
        send_file(output, filename: "#{name}.xls", status: 200)
      when "CARGO_WORK_DETAIL.EXCEL"
        s_date, e_date = get_both_date(params)
        cargo_work_detail = ResultCargo.get_cargo_work_detail_data(:s_date=>s_date,:e_date=>e_date)
        # EXCEL作成クラス Excel creation class
        name = "荷役作業明細一覧"
        excel = Excel::ArrayTbl.new(name)
        excel.mk_excel(cargo_work_detail,true,true)

        output = excel.fin
        send_file(output, filename: "#{name}.xls", status: 200)
        
      when "WORKER_WORK_SUMMARY.EXCEL"
        t_tarm = get_both_date(params)
        wws_data = ResultCargo.get_woker_work_summary_data(:s_date=>t_tarm[0],:e_date=>t_tarm[1])
        format_data = Formatter::WorkerWorkSummaryExcelFormatter.new(
          *wws_data
        ).fetch_data
        excel = Excel::WorkerWorkSummaryExcel.new(format_data,"作業員毎作業一覧出力")
        excel.create()
        output = excel.fin
        send_file(output, filename: "作業員毎作業一覧出力.xls", status: 200)

      when "VACATION_CALENDAR.EXCEL"
        t_yyyy,t_mm = params.values_at(:m_yyyy,:m_mm)
        t_tarm = get_month(Date.parse("#{t_yyyy}/#{t_mm}/01"))
        yyyy = t_tarm[:year].to_s.rjust(4,"0")
        mm = t_tarm[:month].to_s.rjust(2,"0")
        location = Excel::VacationCalendarExcel::OutputLocation
        pattern = "*_休暇カレンダー(#{yyyy}#{mm}_*).xls"
        # -- 
        file_name = get_latest_file(location, pattern)
        last_version = file_name.present? ? get_version(file_name) : -1
        current_version = last_version + 1

        # --
        origin_excel_data = Formatter::VacationCalendarExcelFormatter::WorkBookTemplate
        if file_name.present?
          begin
            origin_excel_data = Parser::VacationCalendarExcelParser.new(location,file_name).parse()
          rescue IOError=> e
            Logger.new(STDOUT).warn "休暇カレンダーの読み込みに失敗しました。#{e.message}"
            flash[:error_msgs] = "休暇カレンダーの読み込みに失敗しました。"
            redirect_to :controller=>:home, :action=>:error; return
          end
        end
        new_file = "休暇カレンダー(#{yyyy}#{mm}_#{current_version})"
        calendar = Vacation.load_calendar(t_tarm[:length][:begin_date],t_tarm[:length][:end_date])
        branches = Branche.where(:cd=>%w(1 2 3 4))
        format_data = Formatter::VacationCalendarExcelFormatter.new(origin_excel_data,t_tarm,calendar,branches).fetch_data # {sheet_name: [[],[],[]]}
        excel = Excel::VacationCalendarExcel.new(format_data,new_file)
        excel.create()
        output = excel.fin
        send_file(output, filename: new_file+".xls", status: 200)
        # --

      else
        render :json => params.to_json, :status => 200
    end
  end

  private
  def set_groval_variables()
    @t_date = Date.strptime(params[:t_date],"%Y/%m/%d")
  end
  
  # 集計期間取得 in) yyyymm => out) yyyy/mm/01:date ~ yyyy/mm/{last}:date | Get the aggregation period: in) yyyymm => out) yyyy/mm/01:date ~ yyyy/mm/{last}:date
  def get_both_date(params)
    s_date = Date.parse(params[:t_s_date])
    e_date = Date.parse(params[:t_e_date])
    return s_date,e_date
  end

  def get_latest_file(dir,match_pattern)
    file_name,version = Dir.glob(match_pattern,base: dir)\
    .map{|fn|
      match = fn.match(/\(\d+_(\d+)\)/)
      ver = match ? match[1].to_i : -1
      [fn,ver]
    }.sort_by{|_,ver| ver}&.last || []

    return file_name
  end

  def get_version(file_name)
    pattern = /\d+_休暇カレンダー\(\d+_(\d)+\).*/
    match = file_name.match(pattern)
    match ? match[1].to_i : -1
  end

  def generate_cargo_work_pdf(csv_type, t_date = nil, params = {})
    # 荷役データ集計 Cargo handling data summary
    daily_cargos, s_date, e_date = 
      case csv_type
      when "CARGO_WORKER_SCHEDULE.CSV"
        [Cargo.where(work_date: t_date).order(:work_date => :asc, :work_no => :asc).group_by(&:work_date), nil, nil]
      when "CARGO_WORKER_RESULT.CSV"
        s_date,e_date = get_both_date(params)
        [ResultCargo.includes(:cargo_request,:result_cargo_worker).where(work_date: s_date..e_date).order(:work_date => :asc, :work_no => :asc).group_by(&:work_date),s_date,e_date]
      end

    work_cd_list = daily_cargos.each_with_object([]) do |(work_date, cargos), ret_list|
      cargos.each { |c| ret_list << c[:work_cd] }
    end

    

    cargo_cd_datas = CargoCdMaster.where(work_cd: work_cd_list.uniq).pluck(:work_cd, :cargo_class).to_h
    cargo_class_datas = CargoClassMaster.where(cargo_class: cargo_cd_datas.values.uniq).pluck(:cargo_class, :name).to_h
    cargo_cd_datas = cargo_cd_datas.transform_values { |cargo_class| cargo_class_datas[cargo_class] }
    rel_data = { cargo_cd_names: cargo_cd_datas }

    # PDF作成クラス PDF creation class
    pdf_class, main_title, sub_title, name_prefix, t_scope =
      case csv_type
      when "CARGO_WORKER_SCHEDULE.CSV"
        [
          Pdf::CargoWorkerSchedulePdf,
          "荷役作業員予定表",
          "対象 #{t_date.strftime('%Y 年 %m 月 %d 日')}",
          "CargoWorkerSchedulePdf",
          (0..0)
        ]
      when "CARGO_WORKER_RESULT.CSV"
        [
          Pdf::CargoWorkerResultPdf,
          "荷役作業員実績表",
          "期間 #{s_date.strftime('%Y 年 %m 月 %d 日')} ～ #{e_date.strftime('%Y 年 %m 月 %d 日')}",
          "CargoWorkerResultPdf",
          (0..99)
        ]
      end

    pdf = pdf_class.new(name_prefix, { page_size: 'A4', page_layout: :landscape, top_margin: 20 }, name: "#{main_title}_#{(t_date || Time.now).strftime('%Y%m%d')}", title: main_title, sub_title: sub_title)
    pdf.create(daily_cargos, rel_data, t_scope: t_scope)
    output = pdf.fin
    send_file(output, filename: "#{pdf.name}.pdf", status: 200)
  end

  def build_cw_first_id_list(t_date,t_class)
    return t_class.where(work_date:@t_date).order(:work_index=>:asc).group_by(&:login_id).transform_values{ |cw| cw.first[:id] }
  end

  def build_assign_data(t_date,cargos)
    assign_data = {}
    return assign_data if cargos.blank?
    branche_color = Branche.all.pluck(:cd,:color).to_h
    cw_first_id = build_cw_first_id_list(cargos.first[:work_date],CargoWorker)
    wokers = Woker.get_latest(t_date).index_by(&:login_id)
    cargos.each do |cargo|
      template_hash = {machines: nil,wokers: nil,memo:""}

      # 配番機械、配番作業員をすべて抽出　⇒　作業カテゴリをユニークで取得
      # 　どちらも登録されていない場合、assign_dataが作成されないのでメモが表示されない。
      #   Cargo::WkTypeで全作業カテゴリのテンプレートデータ作っちゃう？
      # Extract all assigned machines and assigned workers ⇒ Get unique work categories
      # If neither is registered, assign_data will not be created, so the memo will not be displayed.
      # Should we create template data for all work categories using Cargo::WkType?
      
      # wk_types = cargo.cargo_machine.pluck(:wk_type).push(cargo.cargo_worker.pluck(:wk_type)).flatten.uniq
      wk_types = Cargo::WkType.map{|ary| ary[1]}

      wk_data = wk_types.each_with_object({}) do |type,wk_hash|
        wk_hash[type] = template_hash.dup
        wk_hash[type][:memo] = cargo["momo_#{type}".to_sym]
      end
      cargo.cargo_worker.each do |cw|
        woker = wokers[cw[:login_id]]
        next if woker.blank?
        color = branche_color[woker[:branch_cd]]
        wk_data[cw[:wk_type]][:wokers] ||= []
        wk_data[cw[:wk_type]][:wokers][cw[:wk_index]-1] = cw_first_id[cw[:login_id]]==cw[:id] ? woker[:s_name] : "(#{woker[:s_name]})"
        wk_data[cw[:wk_type]][:wokers][cw[:wk_index]-1] += "_#{color.sub(/#/,"")}" if color.present?
      end
      cargo.cargo_machine.each do |cm|
        machine = cm.machine
        color = machine[:color]
        wk_data[cm[:wk_type]][:machines] ||= []
        wk_data[cm[:wk_type]][:machines][cm[:wk_index]-1] = cm.machine[:name]
        wk_data[cm[:wk_type]][:machines][cm[:wk_index]-1] += "_#{color.sub(/#/,"")}" if color.present?
      end
      assign_data[cargo.id] = { work_name: cargo.work_name, wk_types: wk_data }
    end
    assign_data
  end

  def build_assign_result_data(t_date,cargos)
    assign_result_data = {}
    return assign_result_data if cargos.blank?
    branche_color = Branche.all.pluck(:cd,:color).to_h
    cw_first_id = build_cw_first_id_list(cargos.first[:work_date],ResultCargoWorker)
    wokers = Woker.get_latest(t_date).index_by(&:login_id)
    cargos.each do |cargo|
      template_hash = {machines: nil,wokers: nil,memo:""}
      # wk_types = cargo.result_cargo_machine.pluck(:wk_type).push(cargo.result_cargo_worker.pluck(:wk_type)).flatten.uniq
      wk_types = Cargo::WkType.map{|ary| ary[1]}
      wk_data = wk_types.each_with_object({}) do |type,wk_hash|
        wk_hash[type] = template_hash.dup
        wk_hash[type][:memo] = cargo["momo_#{type}".to_sym]
      end
      cargo.result_cargo_worker.each do |cw|
        woker = wokers[cw[:login_id]]
        next if woker.blank?
        color = branche_color[woker[:branch_cd]]
        wk_data[cw[:wk_type]][:wokers] ||= []
        wk_data[cw[:wk_type]][:wokers][cw[:wk_index]-1] = cw_first_id[cw[:login_id]]==cw[:id] ? woker[:s_name] : "(#{woker[:s_name]})"
        wk_data[cw[:wk_type]][:wokers][cw[:wk_index]-1] += "_#{color.sub(/#/,"")}" if color.present?
      end
      cargo.result_cargo_machine.each do |cm|
        machine = cm.machine
        color = machine[:color]
        wk_data[cm[:wk_type]][:machines] ||= []
        wk_data[cm[:wk_type]][:machines][cm[:wk_index]-1] = cm.machine[:name]
        wk_data[cm[:wk_type]][:machines][cm[:wk_index]-1] += "_#{color.sub(/#/,"")}" if color.present?
      end
      assign_result_data[cargo.id] = { work_name: cargo.work_name, wk_types: wk_data }
    end
    assign_result_data
  end

  def build_vacation_wokers_list(cargo_class,t_date)
    cw_cds = cargo_class.where(:work_date=>@t_date).pluck(:login_id)
    vacation_types = VacationType.all.pluck(:id,:time_sheet_name).to_h
    woker_names = Woker.get_latest(t_date).pluck(:login_id,:s_name).to_h

    vacations = Vacation.joins(:user=>:woker)\
      .where(:vacation_day=>@t_date,:branch_cd=>%w(1 2 3 4))\
      .where(:wokers=>{:applicable=>Applicable.get_applicable(2,@t_date)})\
      .where.not(:login_id=>cw_cds)\
      .order('base_no ASC, wokers.branch_cd ASC, wokers.desp_index ASC') #order条件追加　UAT137 #Added order condition UAT137

    v_hash_list = {}
    vacations.each do |vac|
      lid,vt = vac.values_at(:login_id,:vacation_type_id)
      v_name = vacation_types[vt]
      w_name = woker_names[lid]
      # 公休〇×追加 # Add public holidays〇×
      # if vac[:base_no]==6
      #   case vac[:at_work]
      #   when 1
      #     v_name += "〇"
      #   else 2
      #     v_name += "×"
      #   end
      # end

      v_hash_list[v_name] ||= []
      v_hash_list[v_name] << w_name
    end
    v_hash_list

  end
end


