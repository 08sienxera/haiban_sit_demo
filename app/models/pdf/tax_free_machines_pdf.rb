#= 免税軽油稼働実績表PDF作成クラス 
class Pdf::TaxFreeMachinesPdf < Pdf::ExpansionPdfCommon
  # フォントサイズ（ボディ）
  DefFontSizeB = 8
  # 行高さ（ボディ）
  TableRowHeight = 18
  # ページあたりの行数
  TableRow = 25
  # 行幅の割合設定
  TableColumnRatios = [2,*Array.new(31,1),1.5,1]


  # 初期設定
  def initialize(cd,page_condition = {},name:nil,title:nil,sub_title:nil)
    super(cd,page_condition,name:name)
    @title = title || "タイトル未設定"
    @sub_title = sub_title || "サブタイトル未設定"
    @title_under_line_width = 340/13*@title.length
    @max_width = @pdf.bounds.right
  end

  # PDFを作成
  def create(lo_machines,result_cargo_machines,calendar)
    created_time = Time.now()
    table_header,table_body = convert_table_data(lo_machines,result_cargo_machines,calendar)
    make_pdf(@title,@sub_title,table_header,table_body,created_time)
  end


  private
  def make_pdf(title,sub_title,table_header,table_body,created_time)
    page = 1
    table_body.each_slice(TableRow) do |slice|
      if page>1
        next unless slice
        @pdf.start_new_page()
      end
      header(title,sub_title,page,created_time)
      main_table(table_header,slice)
      page +=1
    end
  end
  
  def header(title,sub_title,page,created_time)
    font_size = {
      :main_title=>18,
      :pdf_scope=>10
    }
    under_line_width = @title_under_line_width
    @pdf.text(title,:size=>font_size[:main_title],:align=>:center,:character_spacing=>6)
    @pdf.move_down(3)
    u_line(@pdf.bounds.right/2-under_line_width/2,@pdf.cursor,under_line_width)
    u_line(@pdf.bounds.right/2-under_line_width/2,@pdf.cursor-2,under_line_width)
    @pdf.text(created_time.strftime("%y.%m.%d %H:%M 作成"),:size=>font_size[:pdf_scope],:align=>:right)
    @pdf.text(sub_title,:size=>font_size[:pdf_scope],:align=>:left)
    @pdf.move_up(font_size[:pdf_scope])
    @pdf.text("PAGE    #{page.to_s}",:size=>font_size[:pdf_scope],:align=>:right)
    @pdf.move_up(font_size[:pdf_scope])
    @pdf.bounding_box([@pdf.bounds.left, @pdf.cursor], width: @pdf.bounds.width - 120) do
      @pdf.text("(単位：Hour)",:size=>font_size[:pdf_scope],:align=>:right)
    end
    @pdf.move_down(4)
  end

  def main_table(table_header,table_body)
    column_widths = TableColumnRatios.map {|r| (@max_width/TableColumnRatios.sum*r).floor}
    t_data = table_header + table_body
    t_data += Array.new(TableRow-table_body.length){Array.new(table_header.first.length,"")}
    @pdf.table(t_data, :column_widths => column_widths,:cell_style => { :size => 8,:height => TableRowHeight }) do |t|
      t.row(0).border_bottom_width = 6 # 1行目の下線を無効にする
      t.column(1..31).borders = [:top,:right,:bottom] # 1行目の下線を無効にする
      t.column(1..31).border_lines = [:solid,:dotted,:solid,:solid] # 1行目の下線を無効にする
      [10,20].each{|v| t.column(v).border_lines = [:solid,:solid,:solid,:solid]}
      set_border_width(t,1,outer_width:2)
    end
  end

  def set_border_width(table,def_width,outer_width:nil)
    table.cells.border_width = def_width
    if outer_width
      table.row(0).border_top_width = outer_width
      table.row(-1).border_bottom_width = outer_width
      table.column(0).border_left_width = outer_width
      table.column(-1).border_right_width = outer_width
    end
  end

  
  def convert_table_data(lo_machines,result_cargo_machines,calendar)
    header_data = empty_row_data()
    [[0,"機　械"],[-1,"日"],[-2,"計"]].each do |index,content|
      header_data[index] = {:content=>content,:align=>:center}
    end
    calendar.each.with_index do |(t_date,wh_flg),index|
      header_data[index+1] = {:content=>t_date.strftime("%-d"),:align=>:center,:text_color=>wh_flg==0 ? "000000" : "FFFFFF",:background_color => wh_flg==0 ? "FFFFFF" : "FF5555"}
    end
    return [header_data],[empty_row_data()] if result_cargo_machines.blank?
    # ---
    cell_style = {:align=>:right,:padding=>[5,3,5,0]}
    body_data = lo_machines.map do |id,cd|
      row = empty_row_data()
      row[0] = {:content=>cd,:align=>:center}
      row[-1] = {:content=>"0"}.merge(cell_style)
      row[-2] = {:content=>"0.0"}.merge(cell_style)
    if work_data = result_cargo_machines[cd]
        work_data.transform_values!{|work_time| (work_time.to_f/60).round(1)}.each do |work_date,work_time|
          row[work_date.day] = {:content=>work_time.to_s}.merge(cell_style)
        end
        row[-2] = {:content=>work_data.values.sum.to_s}.merge(cell_style)
        row[-1] = {:content=>work_data.length.to_s}.merge(cell_style)
      end
      row
    end
    # ---
    return [header_data],body_data

  end

  def empty_row_data(in_value="")
    return Array.new(TableColumnRatios.length,in_value)
  end

end

