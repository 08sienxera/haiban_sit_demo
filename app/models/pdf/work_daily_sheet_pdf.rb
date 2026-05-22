#= 出勤日報・残業届PDF作成クラス | Daily attendance report/overtime report PDF creation class
class Pdf::WorkDailySheetPdf < Pdf::ExpansionPdfCommon
  # 行高さ（ヘッダ） | Row height (header)
  HeaderRowHeight = 16
  # 行高さ（ボディ） | Row height (body)
  BodyRowHeight = 11.5
  # ページあたりの行数 | Number of lines per page
  TableRowNum = 60
  # フォントサイズ（ボディ） | Font size (body)
  DefFontSizeB = 7

  # 初期設定 | Initial settings
  def initialize(cd,page_condition = {})
    super(cd,page_condition)
    @title = "作業予定及配番表　並　出勤日報、残業届"
    @title_under_line_width = 0
    @max_width = @pdf.bounds.right - @pdf.bounds.left
  end

  # PDF作成 | PDF creation
  def create(t_date,grouping_woker_data,rel_data)
    days = I18n.t("date.abbr_day_names")
    page_title = @title
    t_date_str = "#{t_date.strftime("%Y 年 %m 月 %d 日(#{days[t_date.wday]})")}"
    created_date_str = "#{Time.now.strftime("%y.%m.%d %H:%M")} 作成"

    #==
    cnt = 0
    grouping_woker_data.each do |( branch_cd, login_id_list )|
      login_id_list.each_slice(TableRowNum).with_index.each do |sliced_id_list,index|
        loop_num = index + 1
        start_new_page() unless cnt == 0
        #== 押印欄 | Seal column
        seal_box()
        #== タイトル、作成日、対象 | Title, creation date, target
        sub_title = "#{rel_data[:branches][branch_cd]}　　　　(業務部)"
        header(page_title,sub_title,t_date_str,created_date_str)
        @pdf.move_cursor_to(715)
        main_table(sliced_id_list,rel_data,loop_num)
        cnt +=1
    
      end
    end
    #--
    # grouping_woker_data.each do |( branch_cd, login_id_list )|
    #   start_new_page() unless cnt == 0
    #   #== 押印欄
    #   seal_box()
    #   #== タイトル、作成日、対象
    #   sub_title = "#{rel_data[:branches][branch_cd]}　　　　(業務部)"
    #   header(page_title,sub_title,t_date_str,created_date_str)
    #   @pdf.move_cursor_to(715)
    #   main_table(login_id_list,rel_data)
    #   cnt +=1
    # end
    #++

  end
  
  private
  def seal_box()
    #== レイアウト設定 | Layout settings
    height = 60 
    layout_left = [
      "勤　労　部",
      ["部　長","部　長","次　長"],
      ["","",""]
    ]
    layout_right = [
      "業　務　部",
      ["部　長","次　長","課　長","課長代理","課長補佐"],
      ["","","","",""]
    ]
    row_height_ratios = [1,1,3];
    #================

    columns_size = [
      layout_left.map{|v| v.instance_of?(Array) ? v.length : 0}.max,
      layout_right.map{|v| v.instance_of?(Array) ? v.length : 0}.max
    ]

    
    edge = height*row_height_ratios[2]/row_height_ratios.sum # 押印欄　正方形の辺の長さ | Seal column: Length of square side
    width = edge*columns_size.sum
    width_left = edge*columns_size[0]
    width_right = edge*columns_size[1]

    #== 勤労部　押印欄 | Labor Department Seal column
    grid_x_size = columns_size[0]
    set_grid(x_size:grid_x_size,y_size:row_height_ratios.sum,width:width_left,height:height,at:[@pdf.bounds.right-width,@pdf.bounds.top])

    cur_pos_y = 0;
    layout_left.each.with_index do |line,index|
      line = [line] unless line.instance_of?(Array)
      cur_pos_x = 0; 
      item_count = line.length
      step_x = grid_x_size/item_count
      step_y = row_height_ratios[index]
      line.each do |value|
        put_grid(value:value,pos:[[cur_pos_x,cur_pos_y],[cur_pos_x+=step_x, cur_pos_y+step_y]],line_weight:1,font_size:DefFontSizeH)
      end
      cur_pos_y += step_y
    end

    #== 業務部　押印欄 | Business Department Seal column
    grid_x_size = columns_size[1]
    set_grid(x_size:grid_x_size,y_size:row_height_ratios.sum,width:width_right,height:height,at:[@pdf.bounds.right-width+width_left,@pdf.bounds.top])

    cur_pos_y = 0;
    layout_right.each.with_index do |line,index|
      line = [line] unless line.instance_of?(Array)
      cur_pos_x = 0; 
      item_count = line.length
      step_x = grid_x_size/item_count
      step_y = row_height_ratios[index]
      line.each do |value|
        put_grid(value:value,pos:[[cur_pos_x,cur_pos_y],[cur_pos_x+=step_x, cur_pos_y+step_y]],line_weight:1,font_size:DefFontSizeH)
      end
      cur_pos_y += step_y
    end
  end

  def header(page_title,sub_title,t_date_str,created_date_str)
    put_text(text:sub_title,pos:[0,750],size:[250,10],font_size:10,align: :left, valign: :bottom,style: :bold)
    put_text(text:page_title,pos:[0,730],size:[250,10],font_size:10,align: :left, valign: :bottom,style: :bold)
    put_text(text:t_date_str,pos:[@pdf.bounds.right/2-75,730],size:[150,10],font_size:8,align: :center,valign: :bottom)
    put_text(text:created_date_str,pos:[@pdf.bounds.right-150,730],size:[150,10],font_size:6,align: :right,valign: :bottom)
  end

  def main_table(login_id_list,rel_data,loop_num)
    start_vpos = @pdf.cursor
    hcolumn_size_l = [2,8,5,6,6,6,6,2,6,6,2] # カラム幅の比率 | Column width ratio
    hcolumn_size_r = [8,5,5,6] # カラム幅の比率 | Column width ratio
    header_height = 20
    header_l = ["No", "氏 名", "手配時間", "作 業 名", "職 種", "備 考", "出 欠","","出勤時間", "退勤時間",""]
    header_width_l = @max_width/(hcolumn_size_l.sum + hcolumn_size_r.sum)*hcolumn_size_l.sum
    header_r = ["汚 れ 手 当 等",["貨 物", "船 内", "体 調", "睡眠時間"]]
    header_width_r = @max_width/(hcolumn_size_l.sum + hcolumn_size_r.sum)*hcolumn_size_r.sum

    #== テーブル描画（ヘッダー | Table drawing (header
    # 左 left
    @pdf.move_cursor_to(start_vpos)
    drow_table_header(columns:header_l,size:hcolumn_size_l,width:header_width_l,height:header_height,offset:[0,0],under_line:false)
    # 右(グリッドレイアウト) | Right (grid layout)
    grid_x_size = hcolumn_size_r.sum
    grid_width = [[hcolumn_size_r.sum],hcolumn_size_r]
    grid_y_size = 2
    set_grid(x_size:grid_x_size,y_size:grid_y_size,width:header_width_r,height:header_height,at:[header_width_l,start_vpos])
    cur_pos_y = 0;
    step_y = 1
    header_r.each.with_index do |line,index1|
      line = [line] unless line.instance_of?(Array)
      cur_pos_x = 0; 
      item_count = line.length
      line.each.with_index do |value,index2|
        step_x = grid_width[index1][index2]
        put_grid(value:value,pos:[[cur_pos_x,cur_pos_y],[cur_pos_x+=step_x, cur_pos_y+step_y]],line_weight:1,font_size:DefFontSizeH)
      end
      cur_pos_y += step_y
    end
    # 共通二重線 | common double line
    put_cell(pos: [0,@pdf.cursor],size: [header_width_l + header_width_r,2])

    
    #== テーブル描画（ボディ | Table drawing (body
    bcolumn_size = [*hcolumn_size_l,*hcolumn_size_r]
    table_data = convert_worker_table_data(login_id_list,rel_data)
    # table_data*=2
    s_no = 1 + TableRowNum*(loop_num-1)
    e_no = TableRowNum * loop_num
    (s_no-1..e_no-1).zip(table_data).each.with_index do |data_with_no,index|
      drow_table_row(data_with_no,bcolumn_size,width:@max_width,offset:[0,0])
    end


    
  end

  def drow_table_header(columns:,size:,width:,height: Pdf::WorkDailySheetPdf::HeaderRowHeight,offset:[0,0],text_direction_settings:{},align_settings:{},under_line:true)
    if width
      cell_width = width / size.sum
    else
      cell_width = @max_width / size.sum
    end
    start_pos_x = 0 + offset[0]
    current_pos_x = start_pos_x
    current_pos_y = @pdf.cursor + offset[1]
    columns.zip(size).each do |value,size|
      put_cell(
        pos: [current_pos_x,current_pos_y],
        size: [size*cell_width, height],
        font_size:DefFontSizeH,
        text: value,
        voffset:0,
        align: :center, 
        valign: :center, 
      )
      current_pos_x = current_pos_x + size*cell_width
    end
    put_cell(
      pos: [start_pos_x,@pdf.cursor],
      size: [width, 2]
    ) if under_line
  end

  def drow_table_row(data_with_no,size,width:,offset:[0,0],text_direction_settings:{},align_settings:{},font_color_settings:{})
    if width
      cell_width = width / size.sum
    else
      cell_width = @max_width / size.sum
    end
    start_pos_x = 0 + offset[0]
    current_pos_x = start_pos_x
    current_pos_y = @pdf.cursor + offset[1]

    row_no = data_with_no[0] +1
    data_2d_ary = data_with_no[1] ? [row_no.to_s, *data_with_no[1]] : size.map{""}

    cnt = 0
    size.zip(data_2d_ary).each_with_index do |(size,value),index|
      value = "" if value=="0"
      align = align_settings[cnt] || :center
      font_color = font_color_settings[row_no-1] && cnt==2 ? font_color_settings[row_no-1] : '000000'
      font_color = 'ff0000' if index==6 && value!="" && data_2d_ary[6]!="公休出"
      # text_direction = text_direction_settings[cnt] || 0
      text_direction = 0
      put_cell(
        pos: [current_pos_x,current_pos_y],
        size: [size*cell_width, Pdf::WorkDailySheetPdf::BodyRowHeight],
        font_size:DefFontSizeB,
        text: value,
        offset:align==:center ? 0 : 2,
        voffset:0,
        align: align,
        text_direction: text_direction,
        font_color: font_color
      )
      current_pos_x = current_pos_x + size*cell_width
      cnt +=1
    end

  end

  def convert_worker_table_data(login_id_list,rel_data)
    table_data = []
    cnt = 0
    login_id_list.each do |login_id|
      temp_line = (0..13).to_a.map{""}
      woker = rel_data[:wokers][login_id]
      user = woker.user
      temp_line[0] = user.blank? ? woker[:s_name] : user[:name]

      v = rel_data[:vacations][login_id]
      cws = rel_data[:cargo_wokers][login_id]
      if v.present? && cws.blank?
        temp_line[1] = rel_data[:vacation_types][v[:vacation_type_id]]
        temp_line[5] = rel_data[:vacation_types][v[:vacation_type_id]]
      else
        if cws.present?
          earliest_time = cws.map { |data| data[:s_time] }.compact.min
          formatted_time = earliest_time&.strftime("%H:%M")
          temp_line[1] = formatted_time || ""
          work_no_list = cws.sort_by(&:work_index).map{|data| data.cargo[:work_no]}.compact
          temp_line[2] = work_no_list.present? ? work_no_list.join(",") : ""
          temp_line[5] = "公休出" if v.present? && v[:base_no]==6
          temp_line[7] = temp_line[1]
        end
      end
      table_data << temp_line
      cnt +=1
    end
    return table_data
  end

end

