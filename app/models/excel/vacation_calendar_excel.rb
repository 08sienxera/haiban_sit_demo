class Excel::VacationCalendarExcel < Excel::ExcelClass
  require File.expand_path('../../../lib/excel/excel_format_builder.rb', __dir__)
  OutputLocation = "public/system/calendars"


  def initialize(format_data,name)
    super(name,:out_dir=>OutputLocation)
    @format_data = format_data
    @worksheets = []
    default = Excel::ExcelFormatBuilder.new(@workbook).borders([1,1,1,1]).valign('center').align('center')
    @border_cell = default.get_format()
    @border_cell_works_on = default.copy().bg_color('yellow').get_format()
    @common_text = default.copy().align('left').borders([0,0,0,0]).get_format()
    @bold_font_border_cell = default.copy().bold(1).get_format()
  end

  def create()
    max_column_size = []
    @format_data[:sheet_count].times do |index|
      column = []
      sheet_data = @format_data[:sheets][index] 
      worksheet = @workbook.add_worksheet(sheet_data[:sheet_name])
      sheet_data[:sheet_data].each_with_index do |row_data, row_idx|
        row_data.each_with_index do |cell_data, col_idx|
          cell_value,works_on = cell_data          
          column << col_idx
          style = cell_value.to_s.start_with?("公") && works_on ? @border_cell_works_on : @border_cell
          worksheet.write(row_idx, col_idx, cell_value,style)
        end
      end
      max_column_size << column.max
      # 最下部に更新日時を追加 Add update date and time at the bottom
      worksheet.write(sheet_data[:sheet_data].length+1, 0, sheet_data[:time_stamp], @common_text)
      @worksheets << worksheet
    end

    # フォーマット調整 Format adjustment
    @worksheets.each.with_index do |ws,index|
      ws.set_column(0, 0, 14)
      ws.set_column(1, max_column_size[index], 6)
    end
  end

  def self.full_output_path
    return Rails.root.join(OutputLocation)
  end


end

