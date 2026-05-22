#= 作業員毎作業一覧エクセル作成クラス Work list Excel creation class for each worker
class  Excel::WorkerWkClassWkPlaceSummaryExcel < Excel::ExcelClass
  require File.expand_path('../../../lib/excel/excel_format_builder.rb', __dir__)

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
    set_print_cofig()
  end

  
  private

  # セルの書式設定オブジェクト cell formatting object
  def init_cell_format()
    base_style = Excel::ExcelFormatBuilder.new(@workbook).font_g().size(10).align('center').vcenter().borders([1,1,1,1]).wrap(true)
    @def_style = Excel::ExcelFormatBuilder.new(@workbook).font_g().size(10).align('center').vcenter().borders([1,1,1,1]).wrap(true).get_format
    @large_font_style = Excel::ExcelFormatBuilder.new(@workbook).font_g().size(12).align('center').vcenter().borders([1,1,1,1]).get_format
    # 色付きセル書式 colored cell format
    @color_cell_styles = {:next_num=>8}
    @format_data[:sheets].each do |sh|
      sh[:sheet_data][1..].each do |row|
        row.map{|r| r[2]}.compact.reject(&:blank?).each do |bg_color|
          next if @color_cell_styles.keys.include?(bg_color)
          color = @workbook.set_custom_color(@color_cell_styles[:next_num],bg_color)
          @color_cell_styles[bg_color] ||= Excel::ExcelFormatBuilder.new(@workbook).font_g().size(10).align('center').vcenter().borders([1,1,1,1]).bg_color(color).wrap(true).get_format
          @color_cell_styles[:next_num] +=1
        end
      end
    end
    # 色文字セル書式 color text cell format
    @color_font_styles = {:next_num=>@color_cell_styles[:next_num]}
    @format_data[:sheets].each do |sh|
      sh[:sheet_data][1..].each do |row|
        row.map{|r| r[1]}.compact.reject(&:blank?).each do |f_color|
          next if @color_font_styles.keys.include?(f_color)
          color = @workbook.set_custom_color(@color_font_styles[:next_num],f_color)
          @color_font_styles[f_color] ||= Excel::ExcelFormatBuilder.new(@workbook).font_g().size(10).align('center').vcenter().borders([1,1,1,1]).color(color).wrap(true).get_format
          @color_font_styles[:next_num] +=1
        end
      end
    end
  end

  def set_data()
    @format_data[:sheet_count].times do |index|
      start_pos = row_pos = 0
      sheet_data = @format_data[:sheets][index] 
      worksheet = @workbook.add_worksheet(sheet_data[:sheet_name])
      @worksheets << worksheet

      row_pos = write_table_header(worksheet,sheet_data,row_pos)
      sheet_data[:sheet_data][1..].each do |row_data|
        row_pos = write_table_row(worksheet,row_data,row_pos,sheet_data[:sheet_name])
      end
    end
  end

  def write_table_header(work_sheet,sheet_data,row_pos)
    sheet_data[:sheet_data][0].each.with_index do |data,i|
      val,f_color,bg_color = data
      style = (i==0 ? @large_font_style : @def_style)
      work_sheet.write(row_pos, i, val, style)
    end
    return row_pos+1
  end
  
  def write_table_row(worksheet, row_data, start_pos, sheet_name=nil)
    row_pos = start_pos
    row_data.each.with_index do |data,k|
      val,f_color,bg_color = data
      style = @def_style
      if bg_color!="#ffffff" && bg_color.present?
        style = @color_cell_styles[bg_color]
      elsif f_color!="#000000" && f_color.present?
        style = @color_font_styles[f_color]
      end
      worksheet.write(row_pos, k, val, style)
    end
    return row_pos + 1
  end

  def set_sheet_style()
    # 行高さ : 25
    # 列幅(1列目) : 15
    # 列幅(2列目以降) : 12
    # Row height: 25 
    # Column width (1st column): 15 
    # Column width (from 2nd column): 12
    @worksheets.each.with_index do |work_sheet,i|
      work_sheet.freeze_panes(1,1) # 見出し固定 Fixed heading
      sheet_data = @format_data[:sheets][i]
      row_size = sheet_data[:sheet_data].size
      col_size =  sheet_data[:sheet_data][0].size
      work_sheet.set_column(0,0,15)
      work_sheet.set_column(1,col_size-1,12)
      row_size.times do |r|
        work_sheet.set_row(r,25)
      end
    end
  end

  def set_print_cofig()
    @worksheets.each do |work_sheet|
      work_sheet.set_paper(8) #A3
      work_sheet.set_landscape #ヨコ  Horizontal
      work_sheet.fit_to_pages(1, 1) # ページ内比率(全体表示) Page ratio (full display)
      work_sheet.set_margins_LR(0.25) # Left,Right　単位：インチ(1inch = 25.4m) Left, Right Unit: inch (1inch = 25.4m)
      work_sheet.set_margins_TB(0.75) # Top,Bottom

    end
  end


end
