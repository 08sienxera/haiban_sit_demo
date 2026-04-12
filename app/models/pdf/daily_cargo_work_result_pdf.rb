#= 日別荷役作業実績PDF作成クラス 
class Pdf::DailyCargoWorkResultPdf < Pdf::ExpansionPdfCommon
  # フォントサイズ（ボディ）
  DefFontSizeB = 5
  # 行高さ（ボディ）
  TableRowHeight = 12
  # ページあたりの行数
  TableRow = 38
  # 列幅の比率設定
  TableColumnRatios = [5,5,15,5,12,4,5,*Array.new(6,4)]


  #初期設定
  def initialize(cd,page_condition = {},name:nil,title:nil,sub_title:nil)
    super(cd,page_condition,name:name)
    @title = title || "タイトル未設定"
    @sub_title = sub_title || "サブタイトル未設定"
    @title_under_line_width = 340/13*@title.length
    @max_width = @pdf.bounds.right
  end

  # ＰＤＦを生成
  def create(daily_work_data)
    created_time = Time.now()
    table_header,table_body = convert_table_data(daily_work_data)
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
    @pdf.move_up(font_size[:main_title]+5)
    @pdf.text(created_time.strftime("%y.%m.%d %H:%M"),:size=>font_size[:pdf_scope],:align=>:right)
    @pdf.move_down(4)
    @pdf.text(sub_title,:size=>font_size[:pdf_scope],:align=>:left)
    @pdf.move_up(font_size[:pdf_scope])
    @pdf.text("PAGE    #{page.to_s}",:size=>font_size[:pdf_scope],:align=>:right)
    @pdf.move_down(8)

  end

  def main_table(table_header,table_body)
    column_widths = TableColumnRatios.map {|r| (@max_width/TableColumnRatios.sum*r).floor}
    t_data = table_header + table_body
    t_data += Array.new(TableRow-table_body.length){empty_row_data()}

    @pdf.table(t_data, :column_widths => column_widths,:row_colors => ["ffffff", "f0f0ff"],:cell_style => {:size=>8,:height=>TableRowHeight,:valign=>:center,:padding=>[0,3,2,3]}) do |t|
      set_border_width(t,0,outer_width:2)
      [[[0,1,3],:center],[[2,4],:left],[(5..12),:right]].each do |cols,align|
        cols.each do |i|
          t.column(i).align = align
        end
      end
      t.row(0).height = TableRowHeight*2
      t.row(0).align = :center
      t.row(0).padding = 0
      t.row(0).border_bottom_width = 1
      t.column(0..TableColumnRatios.length-2).border_right_width = 1
      (1..t_data.length - 1).each do |i|
        if t_data[i][4] == "【日　　計】"
          t.row(i).border_top_width = 1
          t.row(i).border_bottom_width = 1
          t.row(i).column(4).align = :center
          end
      end
    end
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

  
  def convert_table_data(daily_work_data)
    header_data = %w(作業日付 動静番号 本船名 事業区分 貨物分類 総人数 (臨時作業員) ﾄﾗｸﾀ\nｼｮﾍﾞﾙ ｸﾚｰﾝ ﾄﾞｰｻﾞ ﾌｫｰｸ\nﾘﾌﾄ ｽﾄﾗﾄﾞﾙ\nｷｬﾘｱ 機械\n合計).map{|v| v.gsub("\\n","\n")}
    return [header_data],[empty_row_data()] if daily_work_data[:day].length.zero?
    sorted_keys = daily_work_data[:day].keys.sort
    body_data = sorted_keys.each_with_object([]) do |work_date,ret_ary|
      
      daily_work_data[:day][work_date].each do |agg_data|
        row = empty_row_data()
        [
          {:index=>0, :key=>:work_date, :prefix=>nil, :suffix=>nil},
          {:index=>1, :key=>:move_no, :prefix=>nil, :suffix=>nil},
          {:index=>2, :key=>:name, :prefix=>nil, :suffix=>nil},
          {:index=>3, :key=>:type, :prefix=>nil, :suffix=>nil},
          {:index=>4, :key=>:clazz, :prefix=>nil, :suffix=>nil},
          {:index=>5, :key=>:sum_wk, :prefix=>nil, :suffix=>"人 "},
          {:index=>6, :key=>:sum_temp, :prefix=>"( ", :suffix=>"人)"},
          {:index=>7, :key=>:sum_tl, :prefix=>nil, :suffix=>"台 "},
          {:index=>8, :key=>:sum_cr, :prefix=>nil, :suffix=>"台 "},
          {:index=>9, :key=>:sum_bl, :prefix=>nil, :suffix=>"台 "},
          {:index=>10, :key=>:sum_lf, :prefix=>nil, :suffix=>"台 "},
          {:index=>11, :key=>:sum_sc, :prefix=>nil, :suffix=>"台 "},
          {:index=>12, :key=>:sum_mcs, :prefix=>nil, :suffix=>"台 "}
        ].each do |cell_setting|
          index,key,pre,suf = cell_setting.values_at(:index, :key, :prefix, :suffix)
          value = agg_data[key]
          value = value==0 ? "" : [pre,value,suf].map(&:to_s).join
          row[index] = value
        end
        ret_ary << row
      end
      total_data = daily_work_data[:total][work_date]
      row = empty_row_data()
      row[4] = "【日　　計】"
      [
        {:index=>5, :key=>:sum_wk, :prefix=>nil, :suffix=>"人"},
        {:index=>6, :key=>:sum_temp, :prefix=>"(", :suffix=>"人)"},
        {:index=>7, :key=>:sum_tl, :prefix=>nil, :suffix=>"台"},
        {:index=>8, :key=>:sum_cr, :prefix=>nil, :suffix=>"台"},
        {:index=>9, :key=>:sum_bl, :prefix=>nil, :suffix=>"台"},
        {:index=>10, :key=>:sum_lf, :prefix=>nil, :suffix=>"台"},
        {:index=>11, :key=>:sum_sc, :prefix=>nil, :suffix=>"台"},
        {:index=>12, :key=>:sum_mcs, :prefix=>nil, :suffix=>"台"}
      ].each do |cell_setting|
        index,key,pre,suf = cell_setting.values_at(:index, :key, :prefix, :suffix)
        value = total_data[key]
        value = value==0 ? "" : [pre,value,suf].map(&:to_s).join
        row[index] = value
      end
      ret_ary << row
    end
    return [header_data],body_data


  end

  def empty_row_data(in_value="")
    return Array.new(TableColumnRatios.length,in_value)
  end

end

