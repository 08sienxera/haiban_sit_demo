#= 出勤時間表PDF作成クラス 
class Pdf::TimeSheetPdf < Pdf::ExpansionPdfCommon
  # 行高さ（ヘッダ）
  HeaderRowHeight = 16
  # 行高さ（ボディ）
  BodyRowHeight = 19
  # ページあたりの行数
  TableRowNum = 35

  # 初期設定
  def initialize(cd,page_condition = {})
    super(cd,page_condition)
    @title = "業 務 部  出 勤 時 間 表"
    @title_under_line_width = 250
    @max_width = @pdf.bounds.right - @pdf.bounds.left
    @body_top = 0
    @body_under = 600 # 適当に初期化　最終値は横線の最低高さ
  end

  # PDF作成
  def create(t_date,grouping_woker_data,rel_data)
    days = I18n.t("date.abbr_day_names")
    out_line_inner_pos = []
    page_num = 1
    page_title = @title
    sub_title = "#{t_date.strftime("%Y 年 %m 月 %d 日(#{days[t_date.wday]})")}"
    header(page_num,page_title,sub_title)

    v_pos = @pdf.cursor
    index = 0
    grouping_woker_data.each do |branch_cd,login_id_list|
      index +=1
      worker_table(index,v_pos,branch_cd,login_id_list,rel_data,out_line_inner_pos)
    end

    stroke_outline(out_line_inner_pos)
  end
  
  private
  def stroke_outline(out_line_inner_pos)
    line_weight = 2
    width = @pdf.bounds.right - @pdf.bounds.left
    height = @body_top - @body_under

    #= 上下左右
    u_line(@pdf.bounds.left,@body_top,width,width=line_weight)
    v_line(@pdf.bounds.left,@body_top,height,width=line_weight)
    u_line(@pdf.bounds.left,@body_under,width,width=line_weight)
    v_line(@pdf.bounds.right,@body_top,height,width=line_weight)

    #= 中間線
    out_line_inner_pos.each do |x_pos|
      v_line(x_pos,@body_top,height,width=line_weight)
    end
  end

  def header(page_num,page_title,sub_title)
    page_width = @pdf.bounds.right - @pdf.bounds.left
    @pdf.table([
      ["",page_title,""],
      [sub_title,"","#{Time.now.strftime("%y.%m.%d %H:%M")} 作成"],  #24.04.05 16:17 作成
    ],
    :width=>page_width,
    :cell_style=>{
      :width=>page_width/3,
      :border_color => 'FFFFFF',  # 線を非表示にする
      :border_width => 0,  # 線の幅を0に設定
      :valign => :bottom
    }
    ) do
      [[0,:left,12],[1,:center,20],[2,:right,12]].each do |col_setting|
        columns(col_setting[0]).align = col_setting[1]
        columns(col_setting[0]).style(size:col_setting[2])
      end
      columns(1).style(character_spacing:4)
    end

    u_line(@pdf.bounds.right/2 - @title_under_line_width/2,@pdf.bounds.top - 35,@title_under_line_width)
    u_line(@pdf.bounds.right/2 - @title_under_line_width/2,@pdf.bounds.top - 35 +2,@title_under_line_width)
    @pdf.move_down(5)
  end

  def worker_table(index,v_pos,branch_cd,login_id_list,rel_data,out_line_inner_pos)
    branch_nm_font_size = DefFontSizeB
    offset_x_list = []
    col_num = index+index-1
    col_nums = [col_num,col_num+1]
    table_width = @max_width/8
    @pdf.move_cursor_to(v_pos)
    put_text(text:rel_data[:branches][branch_cd],font_size:branch_nm_font_size,pos:[table_width*(col_nums[0]-1)+branch_nm_font_size*2,v_pos])
    v_pos = @pdf.cursor - branch_nm_font_size*1.5
    @body_top = v_pos
    header = %w(No 氏名 時間 内容)
    hcolumn_size = [1,4,2,3] # カラム幅の比率
    table_data,font_color_setting = convert_worker_table_data(login_id_list,rel_data)
    col_nums.each do |num|
      offset_x = table_width*(num-1)
      offset_x_list << offset_x
      #== テーブル描画（ヘッダー
      @pdf.move_cursor_to(v_pos)
      drow_table_header(columns:header,size:hcolumn_size,width:table_width,offset:[offset_x,0])

      #== テーブル描画（ボディ
      bcolumn_size = hcolumn_size
      range = num%2==1 ? (TableRowNum*0..TableRowNum*1-1) : (TableRowNum*1..TableRowNum*2-1)
      # 1回目... 0～34
      # 2回目... 35～69
      t_data = table_data[range] || []
      range.zip(t_data).each.with_index do |data_with_no,index|
        drow_table_row(data_with_no,bcolumn_size,width:table_width,offset:[offset_x,0],font_color_settings:font_color_setting)
      end
    end
    out_line_inner_pos << offset_x_list.min


    
  end

  def drow_table_header(columns:,size:,width:,offset:[0,0],text_direction_settings:{},align_settings:{})
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
        size: [size*cell_width, HeaderRowHeight],
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
    )
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
    size.zip(data_2d_ary) do |size,value|
      value = "" if value=="0"
      align = align_settings[cnt] || :center
      font_color = font_color_settings[row_no-1] && cnt==2 ? font_color_settings[row_no-1] : '000000'
      text_direction = text_direction_settings[cnt] || 0
      put_cell(
        pos: [current_pos_x,current_pos_y],
        size: [size*cell_width, BodyRowHeight],
        font_size:DefFontSizeB,
        text: value,
        offset:align==:center ? 0 : 2,
        voffset:0,
        align: align,
        valign: :center,
        text_direction: text_direction,
        font_color: font_color
      )
      current_pos_x = current_pos_x + size*cell_width
      cnt +=1
      @body_under = current_pos_y - BodyRowHeight
    end

  end
  
  def drow_table_footer(columns:,size:,width:,offset:[0,0],text_direction_settings:{},align_settings:{})
    if width
      cell_width = width / size.sum
    else
      cell_width = @max_width / size.sum
    end
    start_pos_x = 0 + offset[0]
    
    put_cell(
      pos: [start_pos_x,@pdf.cursor],
      size: [width, 2]
    )

    current_pos_x = start_pos_x
    current_pos_y = @pdf.cursor + offset[1]
    cnt = 0
    columns.zip(size).each do |value,size|
      value = "" if value == "0"
      align = align_settings[cnt] || :center
      text_direction = text_direction_settings[cnt] || 0
      put_cell(
        pos: [current_pos_x,current_pos_y],
        size: [size*cell_width, HeaderRowHeight],
        font_size:DefFontSizeB,
        text: value,
        align: align, 
        valign: :center, 
        offset:align==:center ? 0 : 2,
        text_direction:text_direction,
      )
      current_pos_x = current_pos_x + size*cell_width
      cnt +=1
      @body_under = [@body_under,current_pos_y - HeaderRowHeight].min
    end
  end

  def convert_worker_table_data(login_id_list,rel_data)
    # TODO
    ret_ary =  []
    font_color_setting = {}
    cnt = 0
    login_id_list.each do |login_id|
      temp_line = ["","",""]
      woker = rel_data[:wokers][login_id]
      temp_line[0] = woker&.user.blank? ? woker[:s_name] : woker.user[:name] # userがいない場合の対応
      v = rel_data[:vacations][login_id]
      cw = rel_data[:cargo_wokers][login_id]
      if v.present? && cw.blank?
        temp_line[1] = rel_data[:vacation_types][v[:vacation_type_id]]
        font_color_setting[cnt] = 'ff0000'
      elsif cw.present?
        s_time = cw.map{|cw| cw.s_time.present? ? WorkTimeAggregate.mk_time(cw.work_date,cw.s_time,cw.s_time) : nil}.compact.min
        temp_line[1] = s_time ? s_time.strftime("%H:%M") : ""
        work_no_list = cw.sort_by(&:work_index).map{|data| data.cargo[:work_no]}.compact
        temp_line[2] = work_no_list.present? ? work_no_list.join(",") : ""
      end
      
      ret_ary << temp_line
      cnt +=1
    end
    return ret_ary,font_color_setting
  end

end

