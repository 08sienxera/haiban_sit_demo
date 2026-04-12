#= 配番人数表PDF作成の根底クラス 
class Pdf::CargoCommonPdf < Pdf::ExpansionPdfCommon
  # フォントサイズ（ヘッダ）
  DefFontSizeH = 7
  # フォントサイズ（ボディ）
  DefFontSizeB = 9
  # 行高さ（ヘッダ）
  HeaderRowHeight = 16
  # 行高さ（ボディ）
  BodyRowHeight = 19
  # ページあたりの行数
  LineNum = 35
  # 表サイズの大きさ（単位：%）
  CR_TABLE_WIDTH_PER = 81
  # 表サイズの大きさ（単位：%）
  WK_TABLE_WIDTH_PER = 3
  # 表サイズの大きさ（単位：%）
  VAC_TABLE_WIDTH_PER = 16
  # テーブル間のすきま（単位：ピクセル）
  SPACE_BETWEEN_TABLE = 4

  # 初期設定
  def initialize(cd,page_condition = {})
    @body_top = 0
    @body_under = 600 # 適当に初期化　最終値は横線の最低高さ
    super(cd,page_condition)
  end

  # ＸＹ軸の目盛描画
  def stroke_axis()
    @pdf.stroke_axis()
  end

  # ＰＤＦを生成
  def create(t_date,t_date_requests,vac_table_data)
    days = I18n.t("date.day_names")
    @max_width = @pdf.bounds.right - @pdf.bounds.left
    page_num = 1
    page_title = @title
    sub_title = "#{t_date.strftime("%Y 年 %m 月 %d 日(#{days[t_date.wday]})")}"
    header(page_num,page_title,sub_title)

    start_pos = @pdf.cursor
    cr_table(data:t_date_requests,start_pos:start_pos)
    wk_table(data:t_date_requests,start_pos:start_pos)
    vac_table(data:vac_table_data,start_pos:start_pos)
    stroke_sepalate_line()
    drow_matters()
  end
  
  private



  def header(page_num,page_title,sub_title)
    page_width = @pdf.bounds.right - @pdf.bounds.left
    @pdf.table([
      ["",page_title,""],
      [sub_title,"","#{Time.now.strftime("%y.%m.%d %H:%M")} 作成\nPAGE #{page_num}"],  #24.04.05 16:17 作成
    ],
    :width=>page_width,
    :cell_style=>{
      :width=>page_width/3,
      :border_color => 'FFFFFF',  # 線を非表示にする
      :border_width => 0,  # 線の幅を0に設定
      :valign => :bottom
    }
    ) do
      [[0,:left,12],[1,:center,20],[2,:right,10]].each do |col_setting|
        columns(col_setting[0]).align = col_setting[1]
        columns(col_setting[0]).style(size:col_setting[2])
      end
      columns(1).style(character_spacing:4)
    end

    u_line(@pdf.bounds.right/2 - @title_under_line_width/2,@pdf.bounds.top - 35,@title_under_line_width)
    u_line(@pdf.bounds.right/2 - @title_under_line_width/2,@pdf.bounds.top - 35 +2,@title_under_line_width)
    @pdf.move_down(5)
  end

  def cr_table(data:,start_pos:)
    #== レイアウト調整
    text_direction_settings = {13=>1,14=>1,15=>1,16=>1,17=>1,18=>1}
    align_l = {:left=>[1,2,3,8]}
    align_r = {:right=>[4,20]}
    align_settings = {}
    [align_l,align_r].each do |hash|
      hash.each do |key,values|
        values.each do |val|
          align_settings[val] = key
        end
      end
    end

    #== テーブル描画（ヘッダー
    startpos = start_pos
    @pdf.move_cursor_to(startpos)
    header = %w(No 作業名 貨物名 場所 数量 出勤 開始 終了 機械 FM DM WM ｸﾚｰﾝ ローダ バックホー 船内ローダ ドーザ リフト ＳＣ 他 計 )
    hcolumn_size = [1,8,5,3,4,2,2,2,3,1,1,1,1,2,2,2,2,2,2,1,1,] # カラム幅の比率
    drow_table_header(columns:header,size:hcolumn_size,width:@max_width*CR_TABLE_WIDTH_PER/100,offset:[0,0])

    # #== テーブル描画（ボディ
    table_data,footer_data = convert_cr_table_data(data)
    bcolumn_size = hcolumn_size
    # bcolumn_size = [1,8,5,3,4,2,2,2,3,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,] # カラム幅の比率
    (0..34).zip(table_data) do |data_with_no|
      drow_table_row(data_with_no,bcolumn_size,width:@max_width*CR_TABLE_WIDTH_PER/100,offset:[0,0],text_direction_settings:text_direction_settings,align_settings:align_settings)
    end
    
    #== テーブル描画（フッター
    # startpos = @pdf.cursor
    drow_table_footer(columns:footer_data,size:bcolumn_size,width:@max_width*CR_TABLE_WIDTH_PER/100,offset:[0,0],text_direction_settings:text_direction_settings,align_settings:align_settings)
  end

  
  def wk_table(data:,start_pos:)
    #== テーブル描画（ヘッダー
    startpos = start_pos
    @pdf.move_cursor_to(startpos)
    header = %w(作業員数)
    hcolumn_size = [4]
    drow_table_header(columns:header,size:hcolumn_size,width:@max_width*WK_TABLE_WIDTH_PER/100,offset:[@max_width*CR_TABLE_WIDTH_PER/100+SPACE_BETWEEN_TABLE,0])

    # #== テーブル描画（ボディ
    table_data,footer_data = convert_wk_table_data(data)
    bcolumn_size = hcolumn_size
    (0..34).zip(table_data) do |data_with_no|
      drow_table_row(data_with_no,bcolumn_size,width:@max_width*WK_TABLE_WIDTH_PER/100,offset:[@max_width*CR_TABLE_WIDTH_PER/100+SPACE_BETWEEN_TABLE,0])
    end

    #== テーブル描画（フッター
    bcolumn_size = [4] # カラム幅の比率
    drow_table_footer(columns:footer_data,size:bcolumn_size,width:@max_width*WK_TABLE_WIDTH_PER/100,offset:[@max_width*CR_TABLE_WIDTH_PER/100+SPACE_BETWEEN_TABLE,0])
  

  end


  def vac_table(data:,start_pos:)
    #== レイアウト調整
    align_settings = {0=>:left, 1=>:right, 2=>:right, 3=>:right, 4=>:right, 5=>:right, 6=>:right}

    #== テーブル描画（ヘッダー
    startpos = start_pos
    @pdf.move_cursor_to(startpos)
    header = %w(所属 在籍 公休 明休 年休 出勤 公出)
    hcolumn_size = [3,1,1,1,1,1,1] # カラム幅の比率
    drow_table_header(columns:header,size:hcolumn_size,width:@max_width*VAC_TABLE_WIDTH_PER/100,offset:[@max_width*(CR_TABLE_WIDTH_PER+WK_TABLE_WIDTH_PER)/100+SPACE_BETWEEN_TABLE*2,0])

    # #== テーブル描画（ボディ
    table_data,footer_data,wk_type_total = convert_vac_table_data(data)
    bcolumn_size = hcolumn_size # カラム幅の比率

    (0..table_data.count-1).zip(table_data) do |data_with_no|
      drow_table_row(data_with_no,bcolumn_size,width:@max_width*VAC_TABLE_WIDTH_PER/100,offset:[@max_width*(CR_TABLE_WIDTH_PER+WK_TABLE_WIDTH_PER)/100+SPACE_BETWEEN_TABLE*2,0],align_settings:align_settings)
    end
    
    #== テーブル描画（フッター
    startpos = @pdf.cursor
    align_settings[0] = :center
    drow_table_footer(columns:footer_data,size:bcolumn_size,width:@max_width*VAC_TABLE_WIDTH_PER/100,offset:[@max_width*(CR_TABLE_WIDTH_PER+WK_TABLE_WIDTH_PER)/100+SPACE_BETWEEN_TABLE*2,0],align_settings:align_settings)

    #== テーブル下　小計
    
    put_text(text:"ＦＭ",pos:[@max_width*(CR_TABLE_WIDTH_PER+WK_TABLE_WIDTH_PER)/100+SPACE_BETWEEN_TABLE*2+10,@pdf.cursor - (DefFontSizeB*1)])
    put_text(text:"運転",pos:[@max_width*(CR_TABLE_WIDTH_PER+WK_TABLE_WIDTH_PER)/100+SPACE_BETWEEN_TABLE*2+10,@pdf.cursor - (DefFontSizeB*3)])
    put_text(text:"作業員",pos:[@max_width*(CR_TABLE_WIDTH_PER+WK_TABLE_WIDTH_PER)/100+SPACE_BETWEEN_TABLE*2+10,@pdf.cursor - (DefFontSizeB*5)])
    put_text(text:wk_type_total[:fm],pos:[@max_width*(CR_TABLE_WIDTH_PER+WK_TABLE_WIDTH_PER)/100+SPACE_BETWEEN_TABLE*2+10+40,@pdf.cursor - (DefFontSizeB*1)])
    put_text(text:wk_type_total[:op],pos:[@max_width*(CR_TABLE_WIDTH_PER+WK_TABLE_WIDTH_PER)/100+SPACE_BETWEEN_TABLE*2+10+40,@pdf.cursor - (DefFontSizeB*3)])
    put_text(text:wk_type_total[:wk],pos:[@max_width*(CR_TABLE_WIDTH_PER+WK_TABLE_WIDTH_PER)/100+SPACE_BETWEEN_TABLE*2+10+40,@pdf.cursor - (DefFontSizeB*5)])
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
        size: [size*cell_width, Pdf::CargoCommonPdf::HeaderRowHeight],
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
    @body_top = @pdf.cursor
  end

  def drow_table_row(data_with_no,size,width:,offset:[0,0],text_direction_settings:{},align_settings:{})
    if width
      cell_width = width / size.sum
    else
      cell_width = @max_width / size.sum
    end
    start_pos_x = 0 + offset[0]
    current_pos_x = start_pos_x
    current_pos_y = @pdf.cursor + offset[1]

    row_no = data_with_no[0] +1
    data_2d_ary = data_with_no[1]
    data_2d_ary = size.map{""} if data_2d_ary.blank?

    cnt = 0
    size.zip(data_2d_ary) do |size,value|
      value = "" if value=="0"
      align = align_settings[cnt] || :center
      text_direction = text_direction_settings[cnt] || 0
      put_cell(
        pos: [current_pos_x,current_pos_y],
        size: [size*cell_width, Pdf::CargoCommonPdf::BodyRowHeight],
        font_size:DefFontSizeB,
        text: value,
        offset:align==:center ? 0 : 2,
        voffset:0,
        align: align,
        text_direction:text_direction
      )
      current_pos_x = current_pos_x + size*cell_width
      cnt +=1
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
        size: [size*cell_width, Pdf::CargoCommonPdf::HeaderRowHeight],
        font_size:DefFontSizeB,
        text: value,
        align: align, 
        valign: :center, 
        offset:align==:center ? 0 : 2,
        text_direction:text_direction,
      )
      current_pos_x = current_pos_x + size*cell_width
      cnt +=1
      @body_under = [@body_under,current_pos_y - Pdf::CargoCommonPdf::HeaderRowHeight].min
    end
  end


  def stroke_sepalate_line()
    bcolumn_size = [35,2,2,2,2,2,3] # カラム幅の比率
    cell_width = @max_width*CR_TABLE_WIDTH_PER/100/bcolumn_size.sum
    cur_x=0

    bcolumn_size.each do |x|
      cur_x += x
      v_line(cell_width*cur_x,@body_top,@body_top-@body_under,width:0.5)
    end

  end
  def drow_matters()
    if @matters_list
      @matters_list.each do |data|
        put_text(text:data[0],pos:data[1],bg_color:data[2])
      end
    end
  end





# 集計データを表示用の2次元配列に変換する関数
  # == 休暇集計テーブル
  def convert_vac_table_data(vac_table_data)
    table_data = []; footer_data=[]; wk_type_total={fm:0,op:0,wk:0}
    vac_table_data.each do |b_cd,data|
      table_data << ["#{data[:name]}  FM",*data[:datas][:fm].map(&:to_s)] if data[:datas][:fm][0] > 0
      table_data << ["#{data[:name]}  OP",*data[:datas][:op].map(&:to_s)] if data[:datas][:op][0] > 0
      table_data << ["#{data[:name]}  作業",*data[:datas][:wk].map(&:to_s)] if data[:datas][:wk][0] > 0
      wk_type_total[:fm] += data[:datas][:fm][4]
      wk_type_total[:op] += data[:datas][:op][4]
      wk_type_total[:wk] += data[:datas][:wk][4]
    end
    footer_data << "計"
    (1..6).each do |index|
      col_values = table_data.map{|tmp| tmp[index].to_i}
      footer_data << col_values.sum.to_s
    end
    wk_type_total.each{|key,value| wk_type_total[key] = value.to_s}

    return table_data,footer_data,wk_type_total
  end

  
  # == 作業依頼テーブル



  def convert_cr_table_data(cr_table_data)
    table_data = []; footer_data = [];
    line_no = 0
    cr_table_data.each do |cr|
      tmp_line = []
      tmp_line << (line_no +=1).to_s
      tmp_line << cr[:work_name]
      tmp_line << cr[:cargo_name]
      tmp_line << cr[:work_place]
      tmp_line << cr[:quantity]
      tmp_line << cr[:i_time]&.strftime("%H:%M")
      tmp_line << cr[:s_time]&.strftime("%H:%M")
      tmp_line << cr[:e_time]&.strftime("%H:%M")
      tmp_line << cr[:machine_nm]
      tmp_line << cr[:fm_m].to_s
      tmp_line << cr[:dm_m].to_s
      tmp_line << cr[:wm_m].to_s
      tmp_line << cr[:cr_m].to_s
      tmp_line << [cr[:ld_m].to_s, cr[:ld_s].to_s]
      tmp_line << [cr[:bh_m].to_s, cr[:bh_s].to_s]
      tmp_line << [cr[:sl_m].to_s, cr[:sl_s].to_s]
      tmp_line << [cr[:bl_m].to_s, cr[:bl_s].to_s]
      tmp_line << [cr[:lf_m].to_s, cr[:lf_s].to_s]
      tmp_line << [cr[:sc_m].to_s, cr[:sc_s].to_s]
      tmp_line << cr[:ot_m].to_s
      tmp_line << [:fm_m,:dm_m,:wm_m,:cr_m,:ld_m,:ld_s,:bh_m,:bh_s,:sl_m,:sl_s,:bl_m,:bl_s,:lf_m,:lf_s,:sc_m,:sc_s,:ot_m].map{|key| cr[key].to_i}.sum.to_s
      table_data << tmp_line.map do |value|
        if value.instance_of?(Array)
          [(value[0].blank? || value[0]=="0") ? "" : value[0],
              (value[1].blank? || value[1]=="0") ? "" : value[1]]
        else
          (value.blank? || value=="0") ? "" : value 
        end
      end
    
    end

    footer_data = (0..20).map{0}
    footer_data[1] = "合計"
    (13..18).each {|i| footer_data[i] = [0,0]}

    table_data.each do |row|
      (9..20).each do |i|
        if footer_data[i].instance_of?(Array)
          footer_data[i][0] += row[i][0].to_i
          footer_data[i][1] += row[i][1].to_i
        else
          footer_data[i] += row[i].to_i
        end
      end
    end


    footer_data.each.with_index do |col,index|
      if col.instance_of?(Array)
        [0,1].each do |i|
          if footer_data[index][i] == 0
            footer_data[index][i] = ""
          else
            footer_data[index][i] = footer_data[index][i].to_s
          end
        end
      else
        if footer_data[index] == 0
          footer_data[index] = ""
        else
          footer_data[index] = footer_data[index].to_s
        end
      end
    end

    return table_data,footer_data
  end
  
  
  # == 作業員数テーブル
  def convert_wk_table_data(wk_table_data)
    table_data = []; footer_data = [];
    wk_table_data.each do |cr|
      tmp_line = []
      tmp_line << [:hd_w,:db_w,:hs_w,:sn_w,:eg_w,:ot_w].map {|sym| cr[sym].to_i}.sum.to_s
      table_data << tmp_line
    end

    total = 0
    table_data.each do |line|
      total += line[0].to_i
    end
    footer_data << [total.to_s]
    return table_data,footer_data
  end

  


end

