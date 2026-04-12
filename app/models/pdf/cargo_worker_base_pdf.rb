#= 配番表PDF作成の根底クラス 
class Pdf::CargoWorkerBasePdf < Pdf::ExpansionPdfCommon
  # フォントサイズ（ボディ）
  DefFontSizeB = 8
  # 行高さ（ボディ）
  TableRowHeight = 12
  # ページあたりの行数
  TableRow = 37
  # 列幅の比率設定
  TableColumnRatios = [3,1,5,3,4,4,3,2,2,3,1.3,1.3,1.3,1.3,1.3,1.3]
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

  # ＰＤＦ作成
  def create(daily_cargo_list,rel_data,t_scope:)
    @t_scope = t_scope
    t_work_date_list = daily_cargo_list.keys.sort[@t_scope]
    daily_cargo_list.filter!{|work_date,data| t_work_date_list.include?(work_date)}
    body_data = convert_table_data(daily_cargo_list,rel_data,TableColumnRatios.length)
    daily_total_data = convert_daily_total_data(body_data)
    monthly_total_data = convert_monthly_total_data(daily_total_data)
    pagenate_data = t_work_date_list.length>1 ? 
      build_pages_data(body_data,daily_total_data) : build_pages_data(body_data)
    make_pdf(@title,@sub_title,pagenate_data,monthly_total_data)
  end


  private
  def make_pdf(title,sub_title,pagenate_data,total_data)
    pagenate_data = [[Array.new(TableColumnRatios.length,"")]] if pagenate_data.blank?
    pagenate_data.each.with_index do |data,index|
      page = index+1
      header(title,sub_title,page)
      if pagenate_data.length-1==index
        main_table(data,total_data)
        footer()
      else
        main_table(data)
        footer()
        start_new_page() 
      end
    end
  end
  
  def header(title,sub_title,page)
    font_size = {
      :main_title=>14,
      :daily_length=>10
    }
    sepalate_line_width = @title_under_line_width
    @pdf.text(title,:size=>font_size[:main_title],:align=>:center,:character_spacing=>6)
    @pdf.move_down(4)
    u_line(@pdf.bounds.right/2-sepalate_line_width/2,@pdf.cursor,sepalate_line_width)
    @pdf.move_down(4)
    @pdf.text(sub_title,:size=>font_size[:daily_length],:align=>:center)
    @pdf.move_up(font_size[:daily_length])
    @pdf.text("PAGE    #{page.to_s}",:size=>font_size[:daily_length],:align=>:right)
    @pdf.move_down(4)
  end

  def main_table(table_data,footer_data=nil)
    # ------ ヘッダ --------
    t_header = [
      [
        {:content=>"作業日",:colspan=>1,:rowspan=>2},
        {:content=>"No.",:colspan=>1,:rowspan=>2},
        {:content=>"船名・作業名",:colspan=>1,:rowspan=>2},
        {:content=>"貨物(分類)",:colspan=>1,:rowspan=>2},
        {:content=>"貨物名",:colspan=>1,:rowspan=>2},
        {:content=>"荷主名",:colspan=>1,:rowspan=>2},
        {:content=>"場所",:colspan=>1,:rowspan=>2},
        {:content=>"作業時間",:colspan=>2,:rowspan=>1},
        {:content=>"機械",:colspan=>1,:rowspan=>2},
        {:content=>"予定(人)",:colspan=>3,:rowspan=>1},
        {:content=>"実績(人工)",:colspan=>3,:rowspan=>1},
      ].map {|props| props.merge({:size=>9,:align=>:center, :valign=>:center, :height=>12*props[:rowspan],:padding=>[0,0,3,0]})},
      [
        {:content=>"開始"},{:content=>"終了"},
        {:content=>"運転"},{:content=>"作業"},{:content=>"計"},
        {:content=>"社員"},{:content=>"臨時"},{:content=>"計"},
      ].map {|props| props.merge({:size=>9,:align=>:center, :valign=>:center, :height=>12,:padding=>[0,0,3,0]})}
    ]
    column_widths = TableColumnRatios.map {|r| (@max_width/TableColumnRatios.sum*r).floor}
    @pdf.table(t_header, :column_widths => column_widths,:cell_style => { :size => 8 }) do |t|
      t.row(0).background_color = "ffffff"
      set_border_width(t,1,outer_width:2)
    end

    # ------ ボディ --------
    @pdf.move_down(1)
    def_cell_style = {
      :size=>DefFontSizeB,
      :height=>TableRowHeight,
      :borders=>[:left,:right],
      :valign=>:center,
      # :align=>:left,
      :padding=>[0,2,2,2],
    }
    column_aligns = {
      center:[0,7,8],
      right:[1,10,11,12,13,14,15],
    }

    daily_total_pos = []
    t_body = TableRow.times.each_with_object([]) do |index,ary|
      tmp_ary = table_data[index] || Array.new(TableColumnRatios.length,"")
      daily_total_pos << index if tmp_ary[9]=="日　計"
      tmp_ary = tmp_ary.map.with_index do |v,j|
        align = column_aligns.find{|k,v| v.include?(j)}&.first || :left
        {:content=>v,:align=>align}
      end
      ary << tmp_ary
    end

    @pdf.table(t_body,:column_widths => column_widths,:row_colors => ["ffffff", "f0f0ff"],
      :cell_style=>def_cell_style
    ) {|t| 
      set_border_width(t,1,outer_width:2)
      daily_total_pos.each do |row_num|
        t.row(row_num).column(9..15).style(borders: [:top,:left,:right], border_top_width: 2)
        t.row(row_num).column(9).style(align: :center)
      end
    }

    # ------ フッダ --------
    def_cell_style = {
      :size=>DefFontSizeB,
      :height=>TableRowHeight,
      :valign=>:center,
      :padding=>[0,2,2,2],
    }
    column_aligns = {
      center:[9],
      right:[10,11,12,13,14,15],
    }
    footer_data = Array.new(TableColumnRatios.length,"") if footer_data.blank?
    t_footer = footer_data.map.with_index do |v,j|
      align = column_aligns.find{|k,v| v.include?(j)}&.first || :left
      {:content=>v,:align=>align}
    end
    @pdf.table([t_footer],:column_widths => column_widths,:cell_style=>def_cell_style) {|t| set_border_width(t,1,outer_width:2)}

  end

  def footer()
    @pdf.move_down(2)
    font_size = {
      :main_title=>14,
      :daily_length=>10
    }
    @pdf.text(CompName,:size=>font_size[:daily_length],:align=>:right)
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

  
  def convert_table_data(daily_cargo_list,rel_data,col_size)
    raise NotImplementedError
  end


  def convert_daily_total_data(body_data)
    return {} if body_data.blank?
    daily_total_data = body_data.transform_values do |data_lines|
      total_data = empty_row_data()
      total_data[9] = "日　計"
      (10..15).each do |i|
        sum_result = total_data[i].to_i + data_lines.map{|row_data| row_data[i].to_i}.sum
        total_data[i] = sum_result==0 ? "" : sum_result.to_s
      end
      total_data
    end
  end


  def convert_monthly_total_data(daily_total_data)
    return [] if daily_total_data.blank?
    monthly_total_data = empty_row_data()
    monthly_total_data[9] = "合　計"
    daily_total_data.each_value do |data_line|
      (10..15).each do |i|
        monthly_total_data[i] = (monthly_total_data[i].to_i + data_line[i].to_i).to_s
      end
    end
    (10..15).each{|num| monthly_total_data[num] = monthly_total_data[num]=="0" ? "" : monthly_total_data[num]}
    monthly_total_data
  end

  
  def build_pages_data(body_data,daily_total_data={})
    return [] if body_data.blank?
    result_pages = []
    page_data = []
    row_count = 0

    body_data.each do |key,data|
      row_data = [*data,daily_total_data[key]].compact
      row_data.each.with_index do |row,index|
        page_data << row
        row_count +=1
        if row_count == TableRow-1 || (key == body_data.keys.last && index==row_data.length-1)
          result_pages << page_data
          page_data = []
          row_count = 0
        end
      end
      page_data << Array.new(TableColumnRatios.length,"")
    end
    result_pages
  end

  def empty_row_data(value="")
    return Array.new(TableColumnRatios.length,value)
  end

end

