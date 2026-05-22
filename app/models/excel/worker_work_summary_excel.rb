#= 作業員毎作業一覧エクセル作成クラス
#(Constants)->エクセルレイアウトの初期設定
#= Work list Excel creation class for each worker 
#(Constants)->Initial settings for Excel layout
class  Excel::WorkerWorkSummaryExcel < Excel::ExcelClass
  require File.expand_path('../../../lib/excel/excel_format_builder.rb', __dir__)

  DefColWidth = 4.5
  DataNum = 61
  OtHorizontalSize = 29
  OtVerticalSize = 29
  LoHorizontalSize = 17
  LoVerticalSize = 29
  DataSizeH = 65


  def initialize(format_data,name)
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
    @default = Excel::ExcelFormatBuilder.new(@workbook).font_g().size(10).align('center').valign('center')
    @border_cell = Excel::ExcelFormatBuilder.new(@workbook).borders([1,1,1,1])

    @font_colors = {
      :red => Excel::ExcelFormatBuilder.new(@workbook).color('red')
    }
    @bg_colors = {
      :branch => Excel::ExcelFormatBuilder.new(@workbook).bg_color('gray'),
      :name => Excel::ExcelFormatBuilder.new(@workbook).bg_color('silver'),
      :day => Excel::ExcelFormatBuilder.new(@workbook).bg_color('aqua')
    }

    @strong_text = Excel::ExcelFormatBuilder.new(@workbook).font_g().size(14).align('left').bold(1).get_format()
    @table_header = [
      @default.copy().merge(@bg_colors[:branch],@border_cell).get_format(),
      @default.copy().merge(@bg_colors[:day],@border_cell).get_format(),
    ]
    body_def = Excel::ExcelFormatBuilder.new(@workbook).font_g().size(10).valign('center')
    @table_body = [
      body_def.copy().merge(@bg_colors[:name],@border_cell).get_format(), 
      body_def.copy().borders([1,1,0,1]).align('left').get_format(), #上 superior
      body_def.copy().borders([0,0,1,1]).align('left').get_format(), #左中 middle left
      body_def.copy().borders([0,1,1,0]).align('left').get_format(), #右中 middle right
      body_def.copy().borders([1,1,1,1]).align('right').get_format(), #左右下 Left and right
      body_def.copy().borders([0,1,1,1]).align('right').get_format(), #計列 上線なし No overline
    ]
  end

  # セル結合対応のため、書式設定も本メソッド内で実施 Formatting is also done within this method to support cell merging.
  def set_data()
    @format_data[:sheet_count].times do |index|
      sheet_data = @format_data[:sheets][index] 
      start_row = 2
      cur_row = start_row

      worksheet = @workbook.add_worksheet(sheet_data[:sheet_name])
      @worksheets << worksheet
      worksheet.write(0, 0, sheet_data[:sheet_title], @strong_text)
      write_table_header(worksheet,sheet_data[:sheet_data][0],cur_row)
      cur_row +=1
      sheet_data[:sheet_data][1..].each do |row_data|
        write_table_row(worksheet,row_data,cur_row)
        cur_row+=3
      end
    end
  end

  def write_table_header(worksheet, table_header_ary, row)
    col = 0
    worksheet.write(row, col, table_header_ary[0], @table_header[0])
    col += 1
    table_header_ary[1..-2].each do |value|
      worksheet.merge_range(row, col, row, col+1, value, @table_header[1])
      col += 2
    end
    worksheet.write(row, col, table_header_ary[-1], @table_header[0])
  end
  
  def write_table_row(worksheet, table_body_ary, row)
    # [0] =>work_place
    # [1] =>wk_class
    # [2] =>work_class
    # [3] =>sum_orver_time
    # [4] =>orver_time
    col = 0
    worksheet.merge_range(row, col, row+2, col, table_body_ary[0], @table_body[0])
    col += 1
    table_body_ary[1..-2].each do |value|
      cargo_place = value[0] 
      wk_class = value[1] 
      work_class = value[2] 
      sum_orver_time = value[3] 
      orver_time = value[4] 
      worksheet.merge_range(row, col, row, col+1, cargo_place, @table_body[1])
      worksheet.write(row+1, col, wk_class, @table_body[2])
      worksheet.write(row+1, col+1, work_class, @table_body[3])
      worksheet.write(row+2, col, sum_orver_time, @table_body[4])
      worksheet.write(row+2, col+1, orver_time, @table_body[4])
      col += 2
    end
    worksheet.write(row, col, "", @table_body[1])
    worksheet.write(row+1, col, "", @table_body[5])
    worksheet.write(row+2, col, table_body_ary[-1], @table_body[4])
    
  end

  def set_sheet_style()
    @worksheets.each do |ws|
      ws.freeze_panes(3, 1)
      ws.set_column(0, 0, 14)
    end
  end


end
