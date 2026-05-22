#= 現業職労働時間・時間外管理表エクセル作成クラス
#(Constants)->エクセルレイアウトの初期設定
##= On-site work hours/overtime management table Excel creation class 
#(Constants)->Initial settings for Excel layout
class  Excel::WorkTimeSummaryExcel < Excel::ExcelClass
  require File.expand_path('../../../lib/excel/excel_format_builder.rb', __dir__)
  DefColWidth = 4.5
  DataNum = 61
  SumHorizontalSize = 29
  SumVerticalSize = 29
  OtHorizontalSize = 29
  OtVerticalSize = 29
  LoHorizontalSize = 17
  LoVerticalSize = 29
  DataSizeH = 65

  
  #=== ファイル名を返す return file name
  def name()
    return @file_name
  end

  

  #=== エクセルを作成 create excel
  # 引数 argument
  # agg_data : WorkTimeAggregate.get_for_work_time_summary_excel_data
  def create(agg_data)
    init_format()
    @data_size = agg_data.values.map(&:length).max # group_table_dataのデータ数から求める Calculate from the number of data in group_table_data
    sum_data = convert_table_data(agg_data)

    # -- sum_sheet
    sum_sheet = @workbook.add_worksheet("時間外累計")
    write_header(
      sum_sheet,
      "＜　時間外累計（見込み）　＞",
      "全港湾小名浜支部海陸分会",
      Date.today(),
      %w(I1:T2 A2:H2 AA2:AC2 W2:Z2)
    )

    sum_data = set_format_ot(sum_data)    
    set_data(sum_sheet,sum_data)

    set_sheet_style(sum_sheet)
    return

    # -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=


    # -- ot_sheet
    ot_sheet = @workbook.add_worksheet("残業時間（所定）")
    write_header(
      ot_sheet,
      "＜　所定時間外累計（見込）　＞",
      "全港湾小名浜支部海陸分会",
      Date.today(),
      %w(I1:T2 A2:H2 AA2:AC2 W2:Z2)
    )

    ot_data = set_format_ot(ot_data)    
    set_data(ot_sheet,ot_data)

    # -- lo_sheet
    lo_sheet = @workbook.add_worksheet("法廷時間外")
    write_header(
      lo_sheet,
      "＜　法定時間外累計（見込）　＞",
      "全港湾小名浜支部海陸分会",
      Date.today()-1,
      %w(F1:M2 A2:E2 P2:Q2 N2:O2)
    )
    lo_data = set_format_lo(lo_data)    
    set_data(lo_sheet,lo_data)

    set_sheet_style(sum_sheet,ot_sheet,lo_sheet)
  end

  
  private
  def init_format()
    @default = Excel::ExcelFormatBuilder.new(@workbook).font_g().size(10).align('center').wrap(true)
    @border = Excel::ExcelFormatBuilder.new(@workbook).borders([1,1,1,1])
    @red_font = Excel::ExcelFormatBuilder.new(@workbook).color('red')
  end

  def convert_table_data(agg_data)
    # sum...時間外累計（見込み）ot...所定時間外累計 lo...法定時間外累計 sum...Total overtime (estimated) ot...Total outside specified hours lo...Total overtime by law
    sum_group = []
    sum_data = []
    ot_group = []
    ot_data = []
    lo_group = []
    lo_data = []

    agg_data.each do |branch_name,wt_data|
      sum_group << convert_group_table_data(
        :header=>[branch_name, "残業時間\n（所定）","法定時間外\n（平日45時間）","法定時間外\n（日曜含む80時間）","公出\n（平日分）","公出\n（日曜分）","公出\n（平日・日曜合算）",],
        :t_data=>wt_data,
        :require=>[:name,:prescribed,:l_ot_45,:l_ot_80,:wd_base6_num,:hd_base6_num,:sum_base6_num],
        :row_size=>@data_size
      )
      ot_group << convert_group_table_data(
        :header=>[branch_name, "残業\n時間",	"時間\n外",	"累計\n見込", "公出\n(平)", "公出\n(日)",	"公出\n(計)"],
        :t_data=>wt_data,
        :require=>[:name,:p_over_time,:p_early_time,:p_sum_time,:wd_base6_num,:hd_base6_num,:sum_base6_num],
        :row_size=>@data_size
      )
      lo_group << convert_group_table_data(
        :header=>[branch_name, "45\n以内",	"80\n以内",	"所定"],
        :t_data=>wt_data,
        :require=>[:name,:l_ot_45,:l_ot_80,:prescribed],
        :row_size=>@data_size
      )
    end


    # -- sum_data
    num_col = [""]+(1..@data_size).to_a
    empty_row = Array.new(SumHorizontalSize,"")
    num_col.zip(*sum_group).each do |num,data1,data2,data3,data4|
      sum_data << [num,*data1,*data2,*data3,*data4]
    end
    sum_data << empty_row

    avg_row = ["","平均"]
    f_col = %w(C D E F G H - J K L M N O - Q R S T U V - X Y Z AA AB AC)
    f_col.each do |char|
      avg_row << (char=="-" ? "" : "=AVERAGE(#{char}4:#{char}#{@data_size+4})")
    end
    sum_data << avg_row
    sum_data << empty_row
    sum_data << empty_row
    sum_data << empty_row.dup
    sum_data.last[1] = "公出"
    sum_data.last[3] = "日分まで入力済み"

    return sum_data
    # -=-=-=-=-=-=-=-=-=-=-=-==-

    
    # -- ot_data
    num_col = [""]+(1..@data_size).to_a
    empty_row = Array.new(OtHorizontalSize,"")
    num_col.zip(*ot_group).each do |num,data1,data2,data3,data4|
      ot_data << [num,*data1,*data2,*data3,*data4]
    end
    ot_data << empty_row

    avg_row = ["","平均"]
    f_col = %w(C D E F G H - J K L M N O - Q R S T U V - X Y Z AA AB AC)
    f_col.each do |char|
      avg_row << (char=="-" ? "" : "=AVERAGE(#{char}4:#{char}#{@data_size+4})")
    end
    ot_data << avg_row
    ot_data << empty_row
    ot_data << empty_row
    ot_data << empty_row.dup
    ot_data.last[1] = "公出"
    ot_data.last[3] = "日分まで入力済み"

    # -- lo_data
    num_col = [""]+(1..@data_size).to_a
    empty_row = Array.new(LoHorizontalSize,"")
    num_col.zip(*lo_group).each do |num,data1,data2,data3,data4|
      lo_data << [num,*data1,*data2,*data3,*data4]
    end
    lo_data << empty_row

    avg_row = ["","平均"]
    f_col = %w(C D E - G H I - K L M - O P Q)
    f_col.each do |char|
      avg_row << (char=="-" ? "" : "=AVERAGE(#{char}4:#{char}#{@data_size+4})")
    end
    lo_data << avg_row
    lo_data << empty_row

    return sum_data,ot_data,lo_data
  end



  def convert_group_table_data(header:,t_data:,require:,row_size:)
    matrix = []
    matrix << header
    (1..row_size).each do |num|
      row = []
      empty_row = Array.new(header.length,"")
      if data = t_data[num-1]
        require.each do |key|
          row << data[key]
        end
        matrix << row
      else
        matrix << empty_row
      end
    end
    matrix
  end

  def set_data(worksheet,data,offset=[0,0])
    x_offset = 0 + offset[0] 
    y_offset = 2 + offset[1]
    data.each_with_index do |dr,row_index|
      dr.each_with_index do |cel_data,col_index|
        value,format = cel_data
        worksheet.write(row_index + y_offset, col_index + x_offset, value, format)
      end
    end
  end

  def write_header(worksheet,title,to,end_date,rng)
    f = Excel::ExcelFormatBuilder.new(@workbook)
    f.bold(1).font_g()
    worksheet.merge_range(rng[0], title,find_format(f.copy().size(18).align('center')))
    f_align_l = find_format(f.copy().align('left'))
    worksheet.merge_range(rng[1], "TO:#{to}",f_align_l)
    worksheet.merge_range(rng[2], "終了時",f_align_l)
    worksheet.merge_range(rng[3], end_date.strftime("%Y年%m月%d日"),find_format(f.copy().align('right')))

  end


  def set_format_ot(ot_data)
    def_style = @default.copy()
    border_cell = def_style.copy().merge(@border)    
    custom_border_cell = def_style.copy().borders([0,0,0,0])
    matrix_with_style = []
    ot_data[..-3].each.with_index do |row,row_index|
      tmp_row = []
      row.each.with_index do |cell,col_index|
        value = cell
        style = border_cell
        style = style.copy().num_format('0.00') if row_index==ot_data.length-4
        if row_index>0 && row_index<=@data_size && value!=""
          #   ・累計見込＝残業時間＋時間外：40以上で赤文字 ・Cumulative expected = overtime hours + overtime: 40 or more in red
          style = style.copy().merge(@red_font) if [4,11,18,25].include?(col_index) && value>=40
          # ・公出(平)＝work_time_aggregates.wd_base6_num：1以上で赤文字 ・Publication (flat) = work_time_aggregates.wd_base6_num: 1 or more, red text
          style = style.copy().merge(@red_font) if [5,12,19,26].include?(col_index) && value>=1
          # ・公出(日)＝work_time_aggregates.hd_base6_num：3以上で赤文字 ・Publication (Sun) = work_time_aggregates.hd_base6_num: Red text for 3 or more
          style = style.copy().merge(@red_font) if [6,13,20,27].include?(col_index) && value>=3
          # ・公出(計)＝公出(平)＋公出(日)：3以上で赤文字 ・Publication (total) = Publication (average) + Publication (day): 3 or more in red
          style = style.copy().merge(@red_font) if [7,14,21,28].include?(col_index) && value>=3

        end
        tmp_row << [value,style]
      end
      matrix_with_style << tmp_row
    end
    bold_style = def_style.copy().bold(1).cancel(:text_wrap)
    ot_data[-2..].each.with_index do |row,row_index|
      tmp_row = []
      row.each.with_index do |cell,col_index|
        if col_index==1
          tmp_row << [cell,bold_style.copy().align('right')]
        elsif col_index==3
          tmp_row << [cell,bold_style.copy().align('left')]
        else
          tmp_row << cell
        end
      end
      matrix_with_style << tmp_row
    end

    matrix_with_style.each.with_index do |row,row_index|
      row.each.with_index do |cell,col_index|
        if cell.is_a?(Array)
          value,style = cell
          row[col_index][1] = find_format(style)
        end
      end
    end
    matrix_with_style
  end
    
  def set_format_lo(lo_data)
    def_style = @default.copy()
    border_cell = def_style.copy().merge(@border)    
    custom_number_cell = def_style.copy().merge(@border).copy().num_format('0.00')
    matrix_with_style = []
    lo_data.each.with_index do |row,row_index|
      tmp_row = []
      row.each.with_index do |cell,col_index|
        value = cell
        style = border_cell
        style = custom_number_cell if row_index==lo_data.length-2
        if row_index>0 && row_index<=@data_size && value!=""
          style = custom_number_cell if [2,3,6,7,10,11,14,15].include?(col_index)
          # 45以内：4work_time_aggregates.l_ot_45　/60：45.1で赤文字 Within 45: 4work_time_aggregates.l_ot_45 /60: 45.1 in red
          style = style.copy().merge(@red_font) if [2,6,10,14].include?(col_index) && value>45.0
          # 80以内：4work_time_aggregates.l_ot_80　/60：80.1で赤文字 Within 80: 4work_time_aggregates.l_ot_80 /60: 80.1 in red
          style = style.copy().merge(@red_font) if [3,7,11,15].include?(col_index) && value>80.0
        end
        tmp_row << [value,style]
      end
      matrix_with_style << tmp_row
    end
    matrix_with_style.each.with_index do |row,row_index|
      row.each.with_index do |cell,col_index|
        if cell.is_a?(Array)
          value,style = cell
          row[col_index][1] = find_format(style)
        end
      end
    end
    matrix_with_style
  end


  def set_sheet_style(sum_sheet)
  # def set_sheet_style(sum_sheet,ot_sheet,lo_sheet)
    # 時間外累計（見込み） Overtime cumulative total (estimated)
    sum_sheet.freeze_panes(3, 0)
    one_size = 1.6
    col_setting = []
    col_setting << [[0,0],2]
    4.times do |num|
      start1 = 1+(7*num)
      end1 = start1
      col_setting << [[start1,end1],10]
      start2 = 2+(7*num)
      end2 = 2+(7*num)
      col_setting << [[start2,end2],5]
      start2 = 3+(7*num)
      end2 = 4+(7*num)
      col_setting << [[start2,end2],10]
      start2 = 5+(7*num)
      end2 = 6+(7*num)
      col_setting << [[start2,end2],5]
      start2 = 7+(7*num)
      end2 = 7+(7*num)
      col_setting << [[start2,end2],10]
      # start2 = 2+(7*num)
      # end2 = 7+(7*num)
      # col_setting << [[start2,end2],5]
    end
    col_setting.each do |(s,e),size|
      sum_sheet.set_column(s, e, size*one_size)
    end
    sum_sheet.set_row(0,15)
    sum_sheet.set_row(1,22)
    sum_sheet.set_row(2,34)
    (3..@data_size+10).each {|row| sum_sheet.set_row(row,20)}

    return
    # -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=


    
    # 所定時間外累計（見込） Cumulative total outside of designated hours (estimated)
    ot_sheet.freeze_panes(3, 0)
    one_size = 1.6
    col_setting = []
    col_setting << [[0,0],2]
    4.times do |num|
      start1 = 1+(7*num)
      end1 = start1
      col_setting << [[start1,end1],8]
      start2 = 2+(7*num)
      end2 = 7+(7*num)
      col_setting << [[start2,end2],3]
    end
    col_setting.each do |(s,e),size|
      ot_sheet.set_column(s, e, size*one_size)
    end
    ot_sheet.set_row(0,15)
    ot_sheet.set_row(1,22)
    ot_sheet.set_row(2,34)
    (3..@data_size+10).each {|row| ot_sheet.set_row(row,20)}

    # 法定時間外累計（見込） Cumulative total of legal overtime (estimated)
    lo_sheet.freeze_panes(3, 0)
    one_size = 1.6
    col_setting = []
    col_setting << [[0,0],2]
    4.times do |num|
      start1 = 1+(4*num)
      end1 = start1
      col_setting << [[start1,end1],8]
      start2 = 2+(4*num)
      end2 = 4+(4*num)
      col_setting << [[start2,end2],3]
    end
    col_setting.each do |(s,e),size|
      lo_sheet.set_column(s, e, size*one_size)
    end
    lo_sheet.set_row(0,15)
    lo_sheet.set_row(1,22)
    lo_sheet.set_row(2,34)
    (3..@data_size+10).each {|row| lo_sheet.set_row(row,20)}

  end

  #=== セル書式の量産対策、プールから同じフォーマットを返す、無ければ登録 Measures for mass production of cell formats, returning the same format from the pool, registering if not available
  def find_format(format_builder)
    @style_pool ||= []
    b = @style_pool.find{|style_hash,_| format_builder.get_style() == style_hash}
    if b # 同じ書式が見つかった場合 If the same format is found
      return b[1]
    else
      format = format_builder.get_format()
      @style_pool << [format_builder.get_style(),format]
      return format
    end
  end


end
