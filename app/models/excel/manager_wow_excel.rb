#= 作業員毎作業一覧エクセル作成クラス
#(Constants)->エクセルレイアウトの初期設定
#= Work list Excel creation class for each worker 
#(Constants)->Initial settings for Excel layout
class  Excel::ManagerWowExcel < Excel::ExcelClass
  require File.expand_path('../../../lib/excel/excel_format_builder.rb', __dir__)

  def initialize(t_date,wh,threshold_hour,format_data,name)
    @t_date = t_date
    @wh = wh
    @sum_length = {
      :s => wh[:s_date],
      :e => t_date -1
    }
    @threshold_hour = threshold_hour
    @format_data = format_data
    @workbook = nil
    @worksheets = []
    super(name)
  end

  #=== エクセルを作成 create excel
  def create()
    init_cell_format()
    set_data()
    set_sheet_style()
  end

  
  private

  # セルの書式設定オブジェクト cell formatting object
  def init_cell_format()
    def_style = Excel::ExcelFormatBuilder.new(@workbook).font_g().size(10).align('center').vcenter()
    border = Excel::ExcelFormatBuilder.new(@workbook).font_g().size(10).align('center').vcenter().borders([1,1,1,1])

    @default = def_style.get_format
    @border_cell = border.get_format
    
    @border_cell_9 = Excel::ExcelFormatBuilder.new(@workbook).font_g().size(10).align('center').vcenter().borders([1,1,1,1]).size(9).get_format
    @border_cell_12 = Excel::ExcelFormatBuilder.new(@workbook).font_g().size(10).align('center').vcenter().borders([1,1,1,1]).size(12).get_format
    @border_wrap_cell = Excel::ExcelFormatBuilder.new(@workbook).font_g().size(10).align('center').vcenter().borders([1,1,1,1]).wrap(true).get_format
    @border_fnum_cell = Excel::ExcelFormatBuilder.new(@workbook).font_g().size(10).align('center').vcenter().borders([1,1,1,1]).num_format("0.0").get_format
    @big_14 = Excel::ExcelFormatBuilder.new(@workbook).font_g().size(10).align('center').vcenter().bold(1).size(14).get_format
    @big_14_r = Excel::ExcelFormatBuilder.new(@workbook).font_g().size(10).vcenter().bold(1).size(14).align('right').get_format
    @big_14_l = Excel::ExcelFormatBuilder.new(@workbook).font_g().size(10).vcenter().bold(1).size(14).align('left').get_format
    @big_14_red = Excel::ExcelFormatBuilder.new(@workbook).font_g().size(10).align('center').vcenter().bold(1).size(14).color('red').get_format
    @big_18 = Excel::ExcelFormatBuilder.new(@workbook).font_g().size(10).align('center').vcenter().bold(1).size(18).get_format
    light_green = @workbook.set_custom_color(8,"#DAF2D0")
    @big_18_bg_green = Excel::ExcelFormatBuilder.new(@workbook).font_g().align('center').vcenter().bold(1).size(18).bg_color(light_green).get_format
    @big_20 = Excel::ExcelFormatBuilder.new(@workbook).font_g().vcenter().bold(1).size(20).align("left").get_format

  end

  # セル結合対応のため、書式設定も本メソッド内で実施 Formatting is also done within this method to support cell merging.
  def set_data()
    @format_data[:sheet_count].times do |index|
      start_pos = row_pos = 0
      sheet_data = @format_data[:sheets][index] 

      worksheet = @workbook.add_worksheet(sheet_data[:sheet_name])
      @worksheets << worksheet
      row_pos = write_table_header(worksheet,sheet_data,row_pos)
      sheet_data[:sheet_data].each do |row_data|
        row_pos = write_table_row(worksheet,row_data,row_pos)
      end
      row_pos = write_table_footer(worksheet,sheet_data,row_pos)
    end
  end

  def write_table_footer(worksheet,sheet_data,row_pos)
    case sheet_data[:sheet_name]
    when "全体（所定）"
      worksheet.write("B63", "=AVERAGE(B4:B59)", @border_fnum_cell)
    when "全体（法定）"
    else
    end
  end

  def write_table_header(work_sheet,sheet_data,row_pos)
    # ["１ｰ１", "１ｰ２", "２ｰ１", "２ｰ２", "全体（所定）", "全体（法定）"] # ["1-1", "1-2", "2-1", "2-2", "whole (prescribed)", "whole (statutory)"]
    td  = str_mmdd(@t_date)
    tdp = str_mmdd(@sum_length[:e])

    case sheet_data[:sheet_name]
    when "全体（所定）"
      # 1行目 1st line
      work_sheet.write(row_pos, 0, sheet_data[:sheet_title], @big_20)
      work_sheet.merge_range(row_pos, 11, row_pos, 17, "累計見込時間外が", @big_14_r)
      work_sheet.merge_range(row_pos, 18, row_pos, 20, @threshold_hour.to_s, @big_18_bg_green)
      work_sheet.merge_range(row_pos, 21, row_pos, 22, "以上の者は", @big_14_l)
      work_sheet.merge_range(row_pos, 23, row_pos, 24, "赤字", @big_14_red)
      work_sheet.merge_range(row_pos, 25, row_pos, 27, "で表示", @big_14_l)
      # 2行目 2nd line
      row_pos+=1
      %w[１課１係 １課２係 ２課１係 ２課２係].each.with_index do |head_str,index|
        col_pos = index*7
        work_sheet.write(row_pos, col_pos, head_str, @border_cell_12)
        work_sheet.merge_range(row_pos, col_pos+1, row_pos, col_pos+3, "#{td}まで", @border_cell)
        work_sheet.merge_range(row_pos, col_pos+4, row_pos, col_pos+6, "公出", @border_cell)
      end
      # 3行目 3rd line
      row_pos+=1
      4.times do |index|
        col_pos = index*7
        work_sheet.write(row_pos, col_pos+0, "氏名", @border_cell)
        work_sheet.write(row_pos, col_pos+1, "累計", @border_cell)
        work_sheet.write(row_pos, col_pos+2, "見込", @border_cell)
        work_sheet.write(row_pos, col_pos+3, "累計\n合計", @border_wrap_cell)
        work_sheet.write(row_pos, col_pos+4, "平\n日", @border_wrap_cell)
        work_sheet.write(row_pos, col_pos+5, "日\n曜", @border_wrap_cell)
        work_sheet.write(row_pos, col_pos+6, "合\n計", @border_wrap_cell)
      end
    when "全体（法定）"
      # 1行目 1st line
      work_sheet.write(row_pos, 0, sheet_data[:sheet_title], @big_20)
      # 2行目 2nd line
      row_pos+=1
      %w[１課１係 １課２係 ２課１係 ２課２係].each.with_index do |head_str,index|
        col_pos = index*5
        work_sheet.write(row_pos, col_pos, head_str, @border_cell_12)
        work_sheet.merge_range(row_pos, col_pos+1, row_pos, col_pos+4, "#{td}まで", @border_cell)
      end
      # 3行目 3rd line
      row_pos+=1
      4.times do |index|
        col_pos = index*5
        work_sheet.write(row_pos, col_pos+0, "氏名", @border_cell)
        work_sheet.write(row_pos, col_pos+1, "平日\n45\n月間", @border_wrap_cell)
        work_sheet.write(row_pos, col_pos+2, "平日\n45\n日々", @border_wrap_cell)
        work_sheet.write(row_pos, col_pos+3, "平日\n45\n採用", @border_wrap_cell)
        work_sheet.write(row_pos, col_pos+4, "日曜\n80", @border_wrap_cell)
      end

    else
      # 1行目 1st line
      work_sheet.merge_range(row_pos, 0, row_pos, 1, sheet_data[:sheet_title], @border_cell_12)
      work_sheet.merge_range(row_pos, 2, row_pos, 4, tdp+"まで", @border_wrap_cell)
      work_sheet.merge_range(row_pos, 5, row_pos, 6, td+"の予定", @border_wrap_cell)
      work_sheet.merge_range(row_pos, 7, row_pos, 9, "公出", @border_wrap_cell)
      # 2行目 2nd line
      row_pos+=1
      work_sheet.write(row_pos, 0, "氏名", @border_wrap_cell)
      work_sheet.write(row_pos, 1, "#{td}分の勤怠", @border_wrap_cell)
      work_sheet.write(row_pos, 2, "#{tdp}までの時間外", @border_wrap_cell)
      work_sheet.write(row_pos, 3, "#{td}の見込時間外", @border_wrap_cell)
      work_sheet.write(row_pos, 4, "#{td}終了時点での見込時間外", @border_wrap_cell)
      work_sheet.write(row_pos, 5, "作業内容", @border_wrap_cell)
      work_sheet.write(row_pos, 6, "備考", @border_wrap_cell)
      work_sheet.write(row_pos, 7, "平日", @border_wrap_cell)
      work_sheet.write(row_pos, 8, "日曜", @border_wrap_cell)
      work_sheet.write(row_pos, 9, "合計", @border_wrap_cell)

    end
    return row_pos+1
  end
  
  def write_table_row(worksheet, row_data, start_pos)
    row_pos = start_pos
    col_pos = 0

    row_data.each.with_index do |value,index|
      style = nil
      case value.class.name
      when 'Float'
        style = @border_fnum_cell
      else
        style = @border_cell
      end
      worksheet.write(row_pos, col_pos, value, style)
      col_pos+=1
    end
    row_pos+=1
    row_pos

    
  end

  def set_sheet_style()
    @worksheets.each do |work_sheet|
      case work_sheet.name.encode("UTF-8")
      when "全体（所定）"
        [
          [8.22,["A:A","H:H","O:O","V:V"]],
          [4.11,["B:D","I:K","P:R","X:Y"]],
          [2.44,["E:G","L:N","S:U","Z:AB"]]
        ].each {|width,columns| columns.each{|col| work_sheet.set_column(col,width)}}

        [
          [30,[0]],
          [21,[1]],
          [60,[2]]
        ].each {|height,rows| rows.each{|row| work_sheet.set_row(row,height)}}

      when "全体（法定）"
        [
          [10.3,["A:A","F:F","K:K","P:P"]],
          [4.8 ,["B:E","G:J","L:O","Q:T"]]
        ].each {|width,columns| columns.each{|col| work_sheet.set_column(col,width)}}

        [
          [30,[0]],
          [21,[1]],
          [60,[2]]
        ].each {|height,rows| rows.each{|row| work_sheet.set_row(row,height)}}
      else
        [
          ["A:A"  ,15],
          ["B:B"  ,10],
          ["C:E",8.1],
          ["F:G",18],
          ["H:J",5.3],
        ].each {|col, width| work_sheet.set_column(col, width)}

        [
          [0 ,21],
          [1 ,60],
        ].each {|row, height| work_sheet.set_row(row, height)}

      end
    end
  end

  def str_mmdd(date)
    case date.class.name
    when "Date"
      date.strftime("%m/%d")
    else
      raise "Not DateObject"
    end
  end

end
