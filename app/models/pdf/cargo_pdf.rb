class Pdf::CargoPdf < Pdf::ExpansionPdfCommon
  # 作業カテゴリリスト Work category list
  OneCharIdentifier = {hd_w:"ハ",db_w:"土",hs_w:"配",sn_w:"船",eg_w:"沿",ot_w:"他"}
  # 揚積区分リスト Lifting classification list
  IoIdentifier = {0=>"",1=>"揚",2=>"積",3=>"揚積",4=>"その他"}
  DirtIdentifier = {0=>"",1=>"揚",2=>"積",3=>"揚積",4=>"その他"}
  # 作業区分リスト Work classification list
  WorkClassIdentifier = {1=>"本船",2=>"沿岸",9=>"休み"}
  
  # 行高さ（ヘッダー） Row height (header)
  HeaderRowHeight = 16
  # 行高さ（ボディ） Row height (body)
  BodyRowHeight = 23
  # ページあたりの行数（ヘッダとフッタを除く Number of lines per page (excluding headers and footers)
  TableRowNum = 50
  # フォントサイズ（ボディ） Font size (body)
  DefFontSizeB = 8
  # パネル色（配番作業員 Panel color (numbering worker
  WokerPanelColor = 'dcdcdc'
  # パネル色（配番機械 Panel color (numbering machine
  MachinePanelColor = 'dcdcdc'

  # PDFマージン PDF margin
  BottomMargin = 0

  # 初期設定 Initial settings
  def initialize(cd,page_condition = {},name:nil,title:nil)
    super(cd,page_condition,name:name)
    @title = title || "荷役作業予定　及び　配番表"
    @title_under_line_width = 340/13*@title.length
    @max_width = @pdf.bounds.right - @pdf.bounds.left
  end

  # PDF作成 PDF creation
  def create(t_date,cargos,assigned_datas,vacation_wokers,title:@title)
    days = I18n.t("date.day_names")
    page_title = title
    t_date_str = "#{t_date.strftime("%Y 年 %m 月 %d 日(#{days[t_date.wday]})")}"
    created_date_str = "#{Time.now.strftime("%y.%m.%d %H:%M")} 作成"
    # @table_row_num = [cargos.count,TableRowNum].max
    @table_row_num = TableRowNum

    #== タイトル、作成日、対象 Title, creation date, target
    sub_title = "小名浜海陸運送（株）　業務部"

    #== レイアウト崩れ対応 Corresponding to layout collapse
    # main_table関数内に書き込み開始位置（start_list_index）を渡す Pass the write start position (start_list_index) in the main_table function
    # main_table関数内で指定位置に達すると描画を終了し、終了位置を返す When the specified position is reached in the main_table function, the drawing ends and the end position is returned.
    # 終了位置がcargos.length以下の場合、次ページを追加しループを継続する If the end position is less than cargos.length, add the next page and continue the loop
    start_list_index = 0
    count = 0
    loop_flg = true

    # UAT-181 フォント変更 UAT-181 Font change
    @pdf.font(FONT_G)

    while loop_flg do
      raise "無限ループ" if count==100;
      page = count+1
      start_new_page() if page>1
      header(page_title,sub_title,t_date_str,created_date_str,page)
      @pdf.move_cursor_to(740)
      end_list_index = main_table(start_list_index,cargos,assigned_datas,vacation_wokers)
      if cargos.length-1 <= end_list_index
        loop_flg = false
      end
      start_list_index = end_list_index+1
      count+=1
    end

  end
  
  private

  def header(page_title,sub_title,t_date_str,created_date_str,page_num=1)
    # 描画位置、サイズは見ながら調整 Adjust the drawing position and size while looking at it.
    # ハードコーディングしている It's hard-coded
    left = @pdf.bounds.left
    center = @pdf.bounds.right/2 
    right = @pdf.bounds.right
    top = @pdf.bounds.top
    [
      {text:page_title,pos:[center,780],size:[300,22],font_size:22,:align=> :center,:valign=> :bottom,:style=>:bold},
      {text:sub_title,pos:[right,780],size:[400,22],font_size:12,:align=> :right,:valign=> :bottom,:style=>nil},
      {text:"PAGE　#{page_num.to_s}",pos:[right,780-15],size:[400,22],font_size:12,:align=> :right,:valign=> :bottom,:style=>nil},
      {text:t_date_str,pos:[left,780],size:[300,22],font_size:12,:align=> :left,:valign=> :bottom,:style=>:bold},
      {text:created_date_str,pos:[right,top],size:[300,10],font_size:8,:align=> :right,:valign=> :bottom,:style=>:nil},
    ].each do |state|
      case state[:align]
      when :left
        pos_x = state[:pos][0]
      when :right
        pos_x = state[:pos][0] -state[:size][0]
      when :center
        pos_x = state[:pos][0] -state[:size][0]/2
      end
      pos_y = state[:pos][1]
      put_text(text:state[:text],pos:[pos_x,pos_y],size:state[:size],font_size:state[:font_size],:align=> state[:align], :valign=> state[:valign],style: state[:style])
    end

    u_line(@pdf.bounds.right/2 - @title_under_line_width/2,@pdf.bounds.top - 38   ,@title_under_line_width)
    u_line(@pdf.bounds.right/2 - @title_under_line_width/2,@pdf.bounds.top - 38-2 ,@title_under_line_width)

  end

  def test_table_data(cargos,assigned_datas)
    hcolumn_size_l = [1,5,4.5,2.5,2]
    hcolumn_size_c = [2,5]
    hcolumn_size_r = [3,21,21,2,1.2,2,7]
    column_size = hcolumn_size_l.sum + hcolumn_size_c.sum + hcolumn_size_r.sum
    table_data = convert_table_data(cargos,assigned_datas,column_size)
    return table_data

  end

  def main_table(start_index,cargos,assigned_datas,vacation_wokers)
    # start_index => cargosの開始位置を指定 start_index => Specify the starting position of cargos
    start_vpos = @pdf.cursor
    hcolumn_size_l = [1,5,4.5,2.5,2]
    hcolumn_size_c = [2,5]
    hcolumn_size_r = [3,21,21,2,1.2,2,7]
    column_size = hcolumn_size_l.sum + hcolumn_size_c.sum + hcolumn_size_r.sum
    header_height = 20
    header_l = ["No", "作 業 名", "貨 物 名", "場所", "開始"]
    header_width_l = @max_width/column_size*hcolumn_size_l.sum
    header_c = ["船内荷役作業主任者",["FM","DM"]]
    header_width_c = @max_width/column_size*hcolumn_size_c.sum
    header_r = ["荷役機械","取 扱 者","船 内 ・ 沿 岸","労供","人数","出勤","備　　　考"]
    header_width_r = @max_width/column_size*hcolumn_size_r.sum

    #== 準備 Prepare
    # 行描画終了条件の計算（フッタ一致に達するまで Calculating line drawing end condition (until footer match is reached)
    footer_text = ""
    vacation_wokers.each do |v_name,w_name_list|
      footer_text += "＜#{v_name}＞ "
      w_name_list.each {|w_name| footer_text += "#{w_name}  "}
    end

    footer_height = @pdf.height_of(footer_text, size:DefFontSizeB,inline_format: true)
    footer_height = DefFontSizeB if footer_height < DefFontSizeB

    #== テーブル描画（ヘッダー Table drawing (header
    # 左 left
    @pdf.move_cursor_to(start_vpos)
    drow_table_header(columns:header_l,size:hcolumn_size_l,width:header_width_l,height:header_height,offset:[0,0],under_line:false,bg_color:"dddddd")
    # 中(グリッドレイアウト) Medium (grid layout)
    grid_x_size = hcolumn_size_c.sum
    grid_width = [[hcolumn_size_c.sum],hcolumn_size_c]
    grid_y_size = 2
    set_grid(x_size:grid_x_size,y_size:grid_y_size,width:header_width_c,height:header_height,at:[header_width_l,start_vpos])
    cur_pos_y = 0;
    step_y = 1
    header_c.each.with_index do |line,index1|
      line = [line] unless line.instance_of?(Array)
      cur_pos_x = 0; 
      item_count = line.length
      line.each.with_index do |value,index2|
        step_x = grid_width[index1][index2]
        put_grid(value:value,pos:[[cur_pos_x,cur_pos_y],[cur_pos_x+=step_x, cur_pos_y+step_y]],line_weight:0.5,font_size:DefFontSizeH,bg_color:"dddddd")
      end
      cur_pos_y += step_y
    end
    
    # 右 right
    @pdf.move_cursor_to(start_vpos)
    drow_table_header(columns:header_r,size:hcolumn_size_r,width:header_width_r,height:header_height,offset:[@max_width-header_width_r,0],under_line:false,bg_color:"dddddd")

    # 共通二重線 common double line
    put_cell(pos: [0,@pdf.cursor], size: [@max_width,2],line_weight: 0.5)

    #== テーブル描画（ボディ Table drawing (body
    bcolumn_size = [*hcolumn_size_l,*hcolumn_size_c,*hcolumn_size_r]
    wrap_setting = {5=>1,6=>2,6=>2,6=>2,6=>2}

    t_cargos = cargos[start_index..]
    table_data = convert_table_data(t_cargos,assigned_datas,column_size)
    end_index = 0
    total_height = 0
    (start_index..start_index + @table_row_num).zip(table_data).each.with_index do |data_with_no,index|
      t_cargo = t_cargos[index]
      no,data = data_with_no
      next if end_index!=0 

      # work_no
      work_no = t_cargo&.work_no
      # 行の描画高さを計算 Calculate the drawing height of a row
      
      sorce_data = data.present? ? [no.to_s, *data] : bcolumn_size.map{""}

      row_height = calc_row_height(sorce_data,DefFontSizeB,DefFontSizeB)

      end_index = -1 if cargos.length==0
      # リストの最後に到達または描画高さが指定値に到達したら現在位置をend_indexに代入 When the end of the list is reached or the drawing height reaches the specified value, assign the current position to end_index
      if @pdf.cursor-row_height < footer_height+BottomMargin #total_height > end_line
        end_index = start_index + index-1
      else
        total_height += drow_table_row([*data_with_no, work_no],bcolumn_size,width:@max_width,height:row_height,offset:[0,0])
        end_index = start_index + index if table_data.length-1==index
      end

    end

    #== テーブル描画（フッタ Table drawing (footer
    footer_base_ypos = @pdf.cursor
    put_cell(pos: [0,footer_base_ypos],size: [@max_width,footer_height],line_weight: 0.5)
    put_text(text:footer_text,pos: [0+DefFontSizeB,footer_base_ypos],size: [@max_width-DefFontSizeB,footer_height],font_size:DefFontSizeB,valign: :center,style: :bold)

    # 描画完了したデータのcargos位置を返す Returns the cargo position of the data that has been drawn
    return end_index
  end

  def drow_table_header(columns:,size:,width:,height: HeaderRowHeight,offset:[0,0],text_direction_settings:{},align_settings:{},under_line:true,bg_color:nil)
    if width
      cell_width = width / size.sum
    else
      cell_width = @max_width / size.sum
    end
    start_pos_x = 0 + offset[0]
    current_pos_x = start_pos_x
    current_pos_y = @pdf.cursor + offset[1]
    columns.zip(size).each do |value,size|
      text_direction = value.instance_of?(Array) ? 0 : 1
      put_cell(
        pos: [current_pos_x,current_pos_y],
        size: [size*cell_width, height],
        font_size:DefFontSizeH,
        text: value,
        voffset:0,
        align: :center, 
        valign: :center, 
        text_direction: text_direction,
        bg_color: bg_color,
        line_weight: 0.5
      )
      current_pos_x = current_pos_x + size*cell_width
    end
    put_cell(
      pos: [start_pos_x,@pdf.cursor],
      size: [width, 2],
      bg_color: bg_color,
      line_weight: 0.5
    ) if under_line
  end

  def drow_table_row(data_with_no,size,width:,height:,offset:[0,0],text_direction_settings:{},align_settings:{},font_color_settings:{})
    if width
      cell_width = width / size.sum
    else
      cell_width = @max_width / size.sum
    end
    align_settings = {1=>:left,2=>:left,3=>:left,13=>:left,}
    valign_settings = {1=>:top,2=>:top,3=>:top,10=>:center,13=>:top,}
    multiline_mutual_settings = {2=>true,3=>true,}
    start_pos_x = 0 + offset[0]
    current_pos_x = start_pos_x
    present_pos_y = @pdf.cursor
    current_pos_y = @pdf.cursor + offset[1]

    row_no = data_with_no[0] +1
    work_no = data_with_no[2]
    data_2d_ary = data_with_no[1] ? [work_no.to_s, *data_with_no[1]] : size.map{""}
    row_height = height
    cnt = 0
    size.zip(data_2d_ary) do |size,value|
      value = "" if value=="0"
      align = align_settings[cnt] || :center
      valign = valign_settings[cnt] || :center
      multiple_text_reverse = multiline_mutual_settings[cnt] || false
      font_color = font_color_settings[row_no-1] && cnt==2 ? font_color_settings[row_no-1] : '000000'
      text_direction = text_direction_settings[cnt] || 0
      put_cell(
        pos: [current_pos_x,current_pos_y],
        size: [size*cell_width, row_height],
        font_size:DefFontSizeB,
        text: value,
        offset:align==:center ? 0 : 2,
        voffset:0,
        align: align,
        valign: valign,
        text_direction: text_direction,
        font_color: font_color,
        multiple_text_reverse: multiple_text_reverse,
        overflow: :shrink_to_fit,
        line_weight: 0.5
      )
      current_pos_x = current_pos_x + size*cell_width
      cnt +=1
    end
    @pdf.move_cursor_to(present_pos_y-row_height)
    return row_height
  end


  def calc_row_height(table_row_value, min_height, single_char_height)
    calc_results = [min_height]
    max_columns = {:fm=>[1],:mc=>[1],:dm=>[2],:wi_dr=>[3,6],:wk=>[10]}

    # 列ごとにループして計算　MAX値を保持 Loop calculation for each column and keep the MAX value
    table_row_value.each do |cell|
      next unless cell.instance_of?(Hash)
      # 変数初期化 Variable initialization
      wk_type, assign_data = cell.to_a[0]

      max_column = max_columns[wk_type]
      assign_data =[assign_data] unless assign_data.instance_of?(Array)
      assign_data.each.with_index do |v,index|
        next if v.blank?
        wrap_num = 0
        workers, machines, memo = v.values_at(:wokers,:machines,:memo)
        workers ||=[]; machines ||=[]; memo ||="";

        # 作業員　行数 Variable initialization
        worker_row_size = 0
        if workers.present?
          worker_row_size = (workers.length.to_f/max_column[index].to_f).ceil
          worker_row_size = 1 if worker_row_size==0
        end

        # 機械　行数 Machine number of lines
        machine_row_size = 0
        if machines.present?
          machine_row_size = (machines.length.to_f/max_column[index].to_f).ceil
          machine_row_size = 1 if machine_row_size==0
        end

        if wk_type.to_s=="fm"
          wrap_num += ([worker_row_size, machine_row_size].max)
        else
          wrap_num += ([worker_row_size, machine_row_size].max * 2)
        end
        if memo.present?
          wrap_num+=1
        end

        calc_results << (single_char_height * wrap_num + 1)
      end
    end
    require_height = calc_results.max
    require_height

  end


  #== オーバーライド override
  def put_cell(pos:,size:,text:"",text_direction:0,font_size:DefFontSizeB,align: :left,valign: :center,offset:0,voffset:0,overflow: :ellipsis,bg_color:nil,font_color:nil,line_weight:nil,multiple_text_reverse:false)
    unless text.instance_of?(Hash)
      return super(pos:pos,size:size,text:text,text_direction:text_direction,font_size:font_size,align:align,valign:valign,offset:offset,voffset:voffset,overflow: overflow,bg_color:bg_color,font_color:font_color,line_weight:line_weight,multiple_text_reverse: multiple_text_reverse)
    end
    def_color = @pdf.fill_color

    wrap_setting = {:fm=>[1],:mc=>[1],:dm=>[2],:wi_dr=>[3,6],:wk=>[10]}
    workers = []; machines = []; memo = nil;
    wk_type = text.to_a[0][0]
    cargo_rel_data = text.to_a[0][1]
    wrap = wrap_setting[wk_type]
    wrap_num = 0
    space = wk_type==:wi_dr ? 2 : 0
    step = wk_type==:fm ? 1 : 2
    light_font_color = "000000" # 機械の文字を薄くしていたが黒に変更 The text on the machine was made lighter but changed to black.
    
    @pdf.bounding_box(pos, width: size[0], height: size[1], overflow: overflow ) do
      inner_width = (size[0]/wrap.sum) - space
      cargo_rel_data = [cargo_rel_data] unless cargo_rel_data.instance_of?(Array)
      cargo_rel_data.each.with_index do |data,k|
        def_wrap_pos = 0
        if data.present?
          memo = data[:memo] || ""
          workers = data[:wokers] || []
          machines = data[:machines] || []
        end
        if memo.present?
          put_text(text:memo,pos:[(k==0 ? 0 : inner_width*wrap[k-1]+ space * wrap.sum)+offset,size[1]],size:[size[0],font_size],font_size:font_size,align: :left,valign: valign,font_color:light_font_color)
          def_wrap_pos  += 1
        end
        wrap_pos = def_wrap_pos
        # 配番機械パネルの描画 Drawing of numbered machine panel
        machines.each.with_index do |value, index|
          value = value || ""
          name,color = value.split("_")
          if name.present? && color.present?
            bg_color = color
          elsif name.present? && wk_type!=:mc
            bg_color = MachinePanelColor
          else
            bg_color = nil
          end
          # bg_color = "ffffff" unless valid_color?(bg_color) # 無効な色の場合に白色で描画 Draw white if invalid color
          
          if index>0 && index%wrap[k]==0
            wrap_pos += step
          end
          at_x = 0 + inner_width * (index%wrap[k])
          at_x += inner_width*wrap[k-1]+ space * wrap.sum if k>0
          at_x += offset if align==:left
          at_y = size[1] - (voffset * font_size) - (wrap_pos*font_size)

          put_text(text:name.to_s,pos:[at_x,at_y],size:[inner_width-offset,font_size],font_size:font_size,align: align,valign: valign,font_color:light_font_color,bg_color:bg_color)
          
        end
        wrap_pos = def_wrap_pos+step-1
        # 配番作業員パネルの描画 Drawing the numbered worker panel
        workers.each.with_index do |value, index|
          value ||= ""
          name,color = value.split("_")
          
          if name.present? && color.present?
            bg_color = color
          elsif name.present? && wk_type!=:mc
            bg_color = MachinePanelColor
          else
            bg_color = nil
          end
          if index>0 && index%wrap[k]==0
            wrap_pos += step
          end
          at_x = 0 + inner_width * (index%wrap[k])
          at_x += inner_width*wrap[k-1]+ space * wrap.sum if k>0
          at_x += offset if align==:left
          at_y = size[1] - (voffset * font_size) - (wrap_pos*font_size)
          if wk_type!=:mc
            put_text(text:name.to_s,pos:[at_x,at_y],size:[inner_width-offset,font_size],font_size:font_size,align: align,valign: valign,font_color:font_color,style: :bold,bg_color:bg_color)
          else
            put_text(text:name.to_s,pos:[at_x,at_y],size:[inner_width-offset,font_size*2],font_size:font_size,align: align,valign: :top,font_color:light_font_color,overflow: :expand,bg_color:bg_color)
          end
        end
        wrap_pos += 1
      end
        @pdf.transparent(1) {
        def_line = @pdf.line_width
        @pdf.line_width = line_weight if line_weight
        @pdf.stroke_bounds 
        @pdf.line_width = def_line
      }
    end
  end
  def convert_table_data(cargos,assigned_datas,column_size=0)
  # :wokers
    table_data = []
    return [Array.new(column_size,"")] if cargos.blank?
    cargos.each do |cargo|
      tmp_line = (0..12).map{""}
      tmp_line[0] = cargo[:work_name]
      tmp_line[1] = [
        cargo[:cargo_name]||"",
        "#{cargo[:io_flg] ? CargoRequest::IOFlg[cargo[:io_flg].to_i][0] : ""}"
        # "#{cargo[:io_flg] ? IoIdentifier[cargo[:io_flg]] : ""}"
      ]
      tmp_line[2] = [
        cargo[:work_place]||"",
        CargoRequest::DirtFlg[cargo[:dirt_flg].to_i][0]
      ]
      tmp_line[3] = cargo[:s_time]&.strftime("%H:%M") || ""

      # 荷役機械  8,wi-dr Cargo handling machine 8,wi-dr
      tmp_line[6] = {mc: {
        :wokers=>nil,
        :machines=>[cargo[:machine_nm]],
        :memo=>cargo[:momo_mc]
      }}
      # 船内 ・ 沿岸  9,wk Onboard / Coastal 9,wk
      tmp_line[9] = cargo[:rk_np].to_s || ""
      tmp_line[10] = cargo.get_wk_w.to_s
      tmp_line[11] = cargo[:i_time]&.strftime("%H:%M") || ""
      tmp_line[12] = []
      [%i(hd_w db_w hs_w sn_w eg_w ot_w),%i(note)].each do |symbol_ary|
        # [%i(hd_w db_w hs_w sn_w eg_w ot_w),%i(note),%i(matter1),%i(matter2)].each do |symbol_ary|
        tmp_ary = []
        symbol_ary.each do |key|
          prefix = key==:note ? "" : "#{OneCharIdentifier[key]}:"
          tmp_ary << "#{prefix}#{cargo[key]}" if cargo[key].present? && cargo[key] != 0
        end
        tmp_line[12] << tmp_ary.join(" ")
      end
      tmp_line[12] = tmp_line[12]-["",nil]
      tmp_line[12] = "" if tmp_line[12].length==0
      # 荷役作業者、荷役機械 Cargo handling workers, cargo handling machines
      if cargo_assign_data = assigned_datas[cargo[:id]] 
        works = cargo_assign_data[:wk_types]
        # MC
        if mc_works = works["mc"]
          tmp_line[6][:mc][:wokers] = works.dig("mc",:machines)
        end
        # FM    5,fm
        tmp_line[4] = {fm: works["fm"]} if works["fm"].present?
        # DM    6,dm
        tmp_line[5] = {dm: works["dm"]} if works["dm"].present?
        tmp_line[7] = {wi_dr: ["",""]}
        tmp_line[7][:wi_dr][0] = works["wi"] if works["wi"].present?
        tmp_line[7][:wi_dr][1] = works["dr"] if works["dr"].present?
        tmp_line[8] = {wk: works["wk"]} if works["wk"].present?
      end
      table_data << tmp_line
    end
    return table_data
  end
end

