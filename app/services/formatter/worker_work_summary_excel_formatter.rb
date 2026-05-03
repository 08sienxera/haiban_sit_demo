class Formatter::WorkerWorkSummaryExcelFormatter < Formatter::Formatter
  def initialize(tarm,work_summary, rel_data)
    @tarm = tarm
    @work_summary = work_summary
    @rel_data = rel_data
    super()
    convert()
  end

  def convert()
    temp_sheet_data = {
      :sheet_name=>nil,
      :sheet_title=>nil,
      :sheet_data=>nil,
    }
    data = {
      :file_name=>"",
      :sheet_count=>0,
      :sheets=>[]
    }

    branche_hash = Branche.where(:cd=>Branche::WorkerBranchCd).pluck(:cd,:name).to_h
    branch_members, result_cargos, cargos, wt_summary, vacation_summary = @rel_data.values_at(:members, :result_cargos, :cargos, :wt_summary, :vacation_summary)
    if branch_members.length>0
      branch_members.each do |branch_cd,members|
        data[:sheet_count]+=1
        sheet_data = temp_sheet_data.dup
        sheet_data[:sheet_name] = branche_hash[branch_cd]
        sheet_data[:sheet_title] = "#{tarm_start.strftime("%Y/%m/%d")}～#{tarm_end.strftime("%Y/%m/%d")}"

        matrix = []
        matrix << [branche_hash[branch_cd]] + day_str_list + ["計"]
        members.each do |login_id,user_name|
          work_data = @work_summary[login_id]
          row = []
          row << user_name
          total_orver_time = 0.0
          (tarm_start..tarm_end).each do |day|
            day_yyyymmdd = day.strftime("%Y%m%d")
            search_key = "#{login_id}_#{day_yyyymmdd}"

            # 配番作業データあり
            # 休暇データあり
            # **表示データ
            # [     data1    ]
            # [data2L][data2R]
            # [data3L][data3R]
            data1=""; data2L=""; data2R=""; data3L=""; data3R="";
            if work_data && work_data[day] #[0]...result_cargo.id, [1]...result_cargo_woker
              class_name, cargo_wokers = work_data[day]
              work_class, work_place,cargo_name,work_name = class_name=="ResultCargoWorker" ? result_cargos[cargo_wokers.first[:result_cargo_id]] : cargos[cargo_wokers.first[:cargo_id]] # result_cargosがない場合、cargoからデータをとる
              wt = wt_summary[search_key]
              orver_time = wt
                if work_class.blank?
                  work_class_str = ""
                else
                  work_class_str = CargoRequest::WorkClasses.find{|name,cd| cd==work_class.to_s}
                  work_class_str = work_class_str ? work_class_str[0] : ""
                end
                if work_class_str=="沿岸"
                  data1 = "#{work_place}　#{cargo_name}"
                else
                  data1 = "#{work_place}　#{work_name}"
                end
                data2L = work_class_str 
                data2R = CargoRequest::WkClasses[cargo_wokers.first[:wk_class]]
                data3L = total_orver_time.to_s
                data3R = orver_time.to_s
                total_orver_time += orver_time.to_f
            elsif vac = vacation_summary[search_key]
              data2R = vac
              data3L = total_orver_time.to_s
              data3R = "0.0"
            else
              data3L = total_orver_time.to_s
              data3R = "0.0"
            end
            row << [data1,data2L,data2R,data3L,data3R]
          end
          row << total_orver_time.to_s
          matrix << row
        end
        sheet_data[:sheet_data] = matrix
        data[:sheets] << sheet_data
      end
    else
      branche_hash.values.each do |name|
        data[:sheet_count]+=1
        sheet_data = temp_sheet_data.dup
        sheet_data[:sheet_name] = name

        matrix = []
        matrix << [name] + [day_str_list] + ["計"]
        matrix << Array.new((tarm_start..tarm_end).count+2,"")

        sheet_data[:sheet_data] = matrix
        data[:sheets] << sheet_data
      end  
    end
    # ==
    store_data(data)
  end

  private   
    def day_str_list()
      days = I18n.t("date.abbr_day_names")
      date_list = (tarm_start..tarm_end).to_a
      return date_list.map{|date| date.strftime("%-d日(#{days[date.wday]})")}
    end

    def tarm_start
      @tarm[0]
    end
    def tarm_end
      @tarm[1]
    end

end
