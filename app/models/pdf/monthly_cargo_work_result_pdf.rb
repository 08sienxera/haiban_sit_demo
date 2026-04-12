#= 荷役作業実績表PDF作成クラス
class Pdf::MonthlyCargoWorkResultPdf < Pdf::ExpansionPdfCommon
  # フォントサイズ（ボディ）
  DefFontSizeB = 5
  # 行高さ（ボディ）
  TableRowHeight = 12
  # ページあたりの行数
  TableRow = 37
  # 列幅の比率設定
  TableColumnRatios = [1,2] + [1,1]*8
  # フッタに入れる企業名
  CompName = "小名浜海陸運送株式会社"  


  # 初期設定
  def initialize(cd,page_condition = {},name:nil,title:nil,sub_title:nil)
    super(cd,page_condition,name:name)
    @title = title || "タイトル未設定"
    @sub_title = sub_title || "サブタイトル未設定"
    @title_under_line_width = 340/13*@title.length
    @max_width = @pdf.bounds.right
  end

  # PDF作成
  def create(monthly_work_data)
    created_time = Time.now()
    table_header,table_body,table_footer = convert_table_data(monthly_work_data)
    make_pdf(@title,@sub_title,table_header,table_body,table_footer,created_time)
  end


  private
  def make_pdf(title,sub_title,table_header,table_body,table_footer,created_time)
    page = 1
    table_body.each_slice(TableRow) do |slice|
      if page>1
        next unless slice
        @pdf.start_new_page()
      end
      header(title,sub_title,page,created_time)
      main_table(table_header,slice,table_footer)
      footer()
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
    @pdf.move_up(font_size[:main_title]+5)
    @pdf.text(created_time.strftime("%y.%m.%d %H:%M"),:size=>font_size[:pdf_scope],:align=>:right)
    @pdf.move_down(4)
    @pdf.text(sub_title,:size=>font_size[:pdf_scope],:align=>:left)
    @pdf.move_up(font_size[:pdf_scope])
    @pdf.text("PAGE    #{page.to_s}",:size=>font_size[:pdf_scope],:align=>:right)
    @pdf.move_down(8)

  end

  def main_table(table_header,table_body,table_footer)
    column_widths = TableColumnRatios.map {|r| (@max_width/TableColumnRatios.sum*r).floor}
    t_data = table_header + table_body
    t_data += Array.new(TableRow-table_body.length){empty_row_data()}
    t_data += table_footer

    @pdf.table(t_data, :column_widths => column_widths,:row_colors => ["ffffff", "f0f0ff"],:cell_style => {:size=>8,:height=>TableRowHeight,:valign=>:center,:padding=>[0,3,2,3]}) do |t|
      set_border_width(t,0,outer_width:2)
      [[[0],:center],[[1],:left],[(2..TableColumnRatios.length-1),:right]].each do |cols,align|
        cols.each do |i|
          t.column(i).align = align
        end
      end
      t.row(0).height = TableRowHeight*2
      t.row(0).align = :center
      t.row(0).padding = 0
      t.row(0).border_bottom_width = 1
      t.column(0..TableColumnRatios.length-2).border_right_width = 1
      t.row(-1).border_top_width = 1
      t.row(-1).column(1).align = :center
    end
  end

  def footer()
    @pdf.move_down(2)
    font_size = {
      :main_title=>14,
      :daily_length=>10
    }
    @pdf.text(CompName,:size=>font_size[:daily_length],:align=>:right)
  end



  def set_border_width(table,inner_width,outer_width:nil)
    table.cells.border_width = inner_width
    if outer_width
      table.row(0).border_top_width = outer_width
      table.row(-1).border_bottom_width = outer_width
      table.column(0).border_left_width = outer_width
      table.column(-1).border_right_width = outer_width
    end
  end

  
  def convert_table_data(monthly_data)
    header_data = %w(事業区分 貨物 総人数 (臨時作業員) ﾄﾗｸﾀｼｮﾍﾞﾙ クレーン ドーザ フォークリフト ｽﾄﾗﾄﾞﾙｷｬﾘｱ 機械合計)
    header_span = [1,1]+Array.new(8,2)
    header_data = header_data.zip(header_span).map do |value,col_span|
      {:content=>value,:colspan=>col_span}
    end
    return [[header_data],[empty_row_data()],[empty_row_data()]] if monthly_data[:monthly].length.zero?

    format = [
      {:index=>[0,1], :key=>%i(type clazz), :prefix=>nil, :suffix=>nil},
      {:index=>[2,4], :key=>%i(sum_wk sum_temp), :prefix=>nil, :suffix=>"人"},
      {:index=>[6,8,10,12,14,16], :key=>%i(sum_tl sum_cr sum_bl sum_lf sum_sc sum_mcs), :prefix=>nil, :suffix=>"台"},
      {:index=>[3,5,7,9,11,13,15,17], :key=>%i(per_wk per_temp per_tl per_cr per_bl per_lf per_sc per_mcs), :prefix=>nil, :suffix=>"％"},
    ]
    
    body_data = []
    monthly_data[:monthly].each do |_,agg_data|
      row = empty_row_data()
      format.each do |col_setting|
        index_key = col_setting[:index].zip(col_setting[:key])
        pre,suf = col_setting.values_at(:prefix,:suffix)
        index_key.each do |index,key|
          value = agg_data[key]
          if key.start_with?("per_")
            value = value==0 ? "" : "#{pre}#{(value*100).round(1)}#{suf}"
          else
            value = value==0 ? "" : "#{pre}#{value}#{suf}"
          end
          row[index] = value
        end  
      end
      body_data << row
    end
    footer_data = []
    total_agg_data = monthly_data[:total]
    row = empty_row_data()
    row[1]="合　計"
    format[1..].each do |col_setting|
      index_key = col_setting[:index].zip(col_setting[:key])
      pre,suf = col_setting.values_at(:prefix,:suffix)
      index_key.each do |index,key|
        value = total_agg_data[key]
        if key.start_with?("per_")
          value = "#{pre}#{(value*100).round(1)}#{suf}"
        else
          value = "#{pre}#{value}#{suf}"
        end
        row[index] = value
      end  
    end
    footer_data << row
    return [header_data],body_data,footer_data
  end

  def empty_row_data(in_value="")
    return Array.new(TableColumnRatios.length,in_value)
  end

end

