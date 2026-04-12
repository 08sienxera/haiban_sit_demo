class Formatter::VacationCalendarExcelFormatter < Formatter::Formatter
  WorkBookTemplate = {
    :file_name=>"",
    :sheet_count=>0,
    :sheets=>[]
  }
  WorkSheetTemplate = {
    :sheet_name=>"",
    :sheet_title=>"",
    :sheet_data=>[],
    :time_stamp=>"",
  }
  
  def initialize(origin_excel_data,tarm,calendar,branches)
    @origin_excel_data = origin_excel_data
    @tarm = tarm
    @calendar = calendar
    @branches = branches
    super()
    convert()
  end

  def convert()
    formatted_data = Marshal.load(Marshal.dump(@origin_excel_data))
    @branches.pluck(:cd).each.with_index do |(cd),index|
      name_mapping = {
        "1"=>"1-1",
        "2"=>"1-2",
        "3"=>"2-1",
        "4"=>"2-2",
      }
      name = name_mapping[cd]
      sheet_data = Marshal.load(Marshal.dump(WorkSheetTemplate))
      sheet_data[:sheet_name] = name
      sheet_data[:sheet_title] = name
      sheet_data[:time_stamp] = time_stamp_str(DateTime.now)
      sheet_data[:sheet_data] = build_table_data_from_calendar(cd,name)
      insert_or_replace_sheet(formatted_data,name,sheet_data)
    end
    sort_by_sheet_name(formatted_data)
    upadte_sheet_counts(formatted_data)

    store_data(formatted_data)
  end


  private
  def days()
    (@tarm[:length][:begin_date]..@tarm[:length][:end_date]).to_a
  end

  def days_str()
    (@tarm[:length][:begin_date]..@tarm[:length][:end_date]).to_a.map{|date| date.strftime("%d")}
  end

  def time_stamp_str(time)
    "更新日時: #{time&.strftime('%Y-%m-%d %H:%M:%S')}"
  end

  def build_table_data_from_calendar(cd,name)
    column_size = days_str.size
    empty_row = Array.new(column_size,"")
    member_group_by_branch_cd = group_by_branch_cd(@calendar[:menbers])

    # テーブルヘッダー
    header = ["氏名", *days_str]
    
    # テーブルボディ
    body = []
    if (members = member_group_by_branch_cd[cd]).present?
      body += members.map{|member|
        name,login_id = member.values_at("name","login_id")
        vacations = @calendar[:vacations][login_id] || {}
        
        calendar_value = days.map{|day|
          cell_str = ""
          works_on = true
          vacation = vacations.find{|key,vac| key==day}&.last
          if vacation.present?
            works_on = false if !(vacation.works_on? || vacation.holiday_work?)
            cell_str = vacation.str_col_vacation_type
          end
          [cell_str,works_on]
        }
        ret = [name,*calendar_value]
        ret
      }
    end

    # テーブルフッター（集計行
    vacation_count = []
    woker_count = []
    days.each.with_index do |_,index|
      vacation_sum = body.map {|row|
        row[index+1][1] ? 0 : 1
      }.sum
      vacation_count << vacation_sum
      woker_count << (members.present? ? members.size - vacation_sum : 0)
    end
    footer = [
      ["休暇者数", *vacation_count],
      ["出勤者数", *woker_count]
    ]

    # 結合＆返却
    ret = [header,*body,*footer]
    ret
  end

  def insert_or_replace_sheet(data,name,sheet_data)
    same_name_index = data[:sheets].find_index{|sheet| sheet[:sheet_name]==name}
    if same_name_index
      data[:sheets][same_name_index] = sheet_data
    else
      data[:sheets] << sheet_data
    end
  end

  def sort_by_sheet_name(formatted_data)
    formatted_data[:sheets] = formatted_data[:sheets].sort_by{|sheet| sheet[:sheet_name]}
  end
  def upadte_sheet_counts(formatted_data)
    formatted_data[:sheet_count] = formatted_data[:sheets].size
  end

  def group_by_branch_cd(menbers)
    return {} if menbers.blank?
    return menbers.group_by{|member| member["branch_cd"]}
  end

end
