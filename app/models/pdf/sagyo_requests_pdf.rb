#= 作業依頼書PDF作成クラス
class Pdf::SagyoRequestsPdf < Pdf::PdfCommon

  # 作業カテゴリリスト
  OneCharIdentifier = {hd_w:"ハ",db_w:"土",hs_w:"配",sn_w:"船",eg_w:"沿",ot_w:"他"}
  # 揚積区分リスト
  IoIdentifier = {0=>"",1=>"揚",2=>"積",3=>"揚積",4=>"その他"}
  # 作業区分リスト
  WorkClassIdentifier = {1=>"本船",2=>"沿岸",9=>"休み"}

  # フォントサイズ（ボディ）
  DefFontSizeB = 7
  # 行高さ（ヘッダー）
  HeaderRowHeight = 11
  # 行高さ（ボディ）
  BodyRowHeight = 33
  # 行高さ（ヘッダー）
  LineNum = 12

  # XY軸目盛の描画
  def stroke_axis()
    @pdf.stroke_axis()
  end

  # PDF作成
  def create(t_date,cargo_requests)
    days = I18n.t("date.day_names")
    @max_width = @pdf.bounds.right - @pdf.bounds.left
    @sepalate_line_x_pos_list = []
    if cargo_requests.length>0
      cargo_requests.values.each.with_index do |cr_list,index|
        @matters_list = []
        work_class_name = WorkClassIdentifier[cr_list[0][:work_class]]
        page_num = index + 1
        page_title = "#{work_class_name}作業依頼書"
        sub_title = "#{cr_list[0][:department_nm]}課\n#{t_date.strftime("%Y 年 %m 月 %d 日(#{days[t_date.wday]})")}"
        start_new_page() unless index == 0
        header(page_num,page_title,sub_title)
        body(cr_list)
        stroke_sepalate_line()
        drow_matters()
      end
    else
      work_class_name = ""
      page_num = 1
      page_title = "作業依頼書"
      sub_title = "課\n#{t_date.strftime("%Y 年 %m 月 %d 日(#{days[t_date.wday]})")}"
      header(page_num,page_title,sub_title)
      body([])
    end
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

    u_line(@pdf.bounds.right/2 - 100,500-5,200)
    u_line(@pdf.bounds.right/2 - 100,500-5+2,200)
    @pdf.move_down(5)
  end

  
  def body(cr_list)
    #== テーブル描画（ヘッダー
    header = %w(No 作業名 貨物名 場所 数量 時間 機械 FM DM WM ｸﾚｰﾝ ローダ バックホー 船内ローダ ブル リフト ＳＣ 他 運転 作業 出勤 備考)
    hcolumn_size = [1,5,4,2,3,2,2,1,1,1,1,2,2,2,2,2,2,1,1,1,2,4] # カラム幅の比率
    drow_table_header(header,hcolumn_size)
    
    #== テーブル描画（ボディ
    bcolumn_size = hcolumn_size # カラム幅の比率
    (0..LineNum).zip(cr_list) do |cr_with_no|
      drow_table_row(cr_with_no,bcolumn_size)
    end
    
    #== テーブル描画（フッター
    footer = Array.new(bcolumn_size.length,"")
    sum_fm_m = 0
    sum_dm_m = 0
    sum_wm_m = 0
    sum_cr_m = 0
    sum_ld_m = 0
    sum_ld_s = 0
    sum_bh_m = 0
    sum_bh_s = 0
    sum_sl_m = 0
    sum_sl_s = 0
    sum_bl_m = 0
    sum_bl_s = 0
    sum_lf_m = 0
    sum_lf_s = 0
    sum_sc_m = 0
    sum_sc_s = 0
    sum_ot_m = 0
    sum_hs_w = 0
    sum_wk_w = 0

    cr_list.each do |cr|
      sum_fm_m += cr[:fm_m].to_i
      sum_dm_m += cr[:dm_m].to_i
      sum_wm_m += cr[:wm_m].to_i
      sum_cr_m += cr[:cr_m].to_i
      sum_ld_m += cr[:ld_m].to_i
      sum_ld_s += cr[:ld_s].to_i
      sum_bh_m += cr[:bh_m].to_i
      sum_bh_s += cr[:bh_s].to_i
      sum_sl_m += cr[:sl_m].to_i
      sum_sl_s += cr[:sl_s].to_i
      sum_bl_m += cr[:bl_m].to_i
      sum_bl_s += cr[:bl_s].to_i
      sum_lf_m += cr[:lf_m].to_i
      sum_lf_s += cr[:lf_s].to_i
      sum_sc_m += cr[:sc_m].to_i
      sum_sc_s += cr[:sc_s].to_i
      sum_ot_m += cr[:ot_m].to_i
      sum_hs_w += cr[:hs_w].to_i
      sum_wk_w += cr[:wk_w].to_i
    end
    
    footer[1] = "合計"
    footer[7] = sum_fm_m.to_s
    footer[8] = sum_dm_m.to_s
    footer[9] = sum_wm_m.to_s
    footer[10] = sum_cr_m.to_s
    footer[11] = [sum_ld_m.to_s,sum_ld_s.to_s]
    footer[12] = [sum_bh_m.to_s,sum_bh_s.to_s]
    footer[13] = [sum_sl_m.to_s,sum_sl_s.to_s]
    footer[14] = [sum_bl_m.to_s,sum_bl_s.to_s]
    footer[15] = [sum_lf_m.to_s,sum_lf_s.to_s]
    footer[16] = [sum_sc_m.to_s,sum_sc_s.to_s]
    footer[17] = sum_ot_m.to_s
    footer[18] = sum_hs_w.to_s
    footer[19] = sum_wk_w.to_s

    drow_table_footer(footer,bcolumn_size)

  end

  
  def drow_table_header(values,size)
    cell_width = @max_width / size.sum
    current_pos_x = 0
    current_pos_y = @pdf.cursor

    values.zip(size).each do |value,size|
      put_cell(
        pos: [current_pos_x,current_pos_y],
        size: [size*cell_width, Pdf::SagyoRequestsPdf::HeaderRowHeight],
        text: value,
        voffset:0,
          align: :center, 
        valign: :center, 
      )
      current_pos_x = current_pos_x + size*cell_width
    end
    put_cell(
      pos: [0,@pdf.cursor],
      size: [@max_width, 2]
    )

    @body_top = @pdf.cursor
  end


  def drow_table_row(cr_with_no,size) #--cr_with_no ->[n番目,cargo_request]
    cell_width = @max_width / size.sum
    current_pos_x = 0
    current_pos_y = @pdf.cursor

    row_no,cargo_request = cr_with_no
    tmp_line = Array.new(size.length,"")
    if cargo_request
      tmp_line[0] = (row_no+1).to_s
      tmp_line[1] = cargo_request[:work_name]
      tmp_line[2] = [
        cargo_request[:cargo_name],
        "　　　　　　　　#{cargo_request[:io_flg] ? Pdf::SagyoRequestsPdf::IoIdentifier[cargo_request[:io_flg]] : ""}"
      ]
      tmp_line[3] = [
        cargo_request[:work_place],
        cargo_request[:dirt_flg]==0 ? "" : "汚れ"
      ]
      tmp_line[4] = cargo_request[:quantity]
      if cargo_request[:s_time] || cargo_request[:e_time]
        tmp_line[5] = ["#{cargo_request[:s_time]&.strftime("%H:%M")}～", "　#{cargo_request[:e_time]&.strftime("%H:%M")}"]
      end
      tmp_line[6] = cargo_request[:machine_nm]
      tmp_line[7] = cargo_request[:fm_m].to_s
      tmp_line[8] = cargo_request[:dm_m].to_s
      tmp_line[9] = cargo_request[:wm_m].to_s
      tmp_line[10] = cargo_request[:cr_m].to_s
      tmp_line[11] = [cargo_request[:ld_m].to_s,cargo_request[:ld_s].to_s]
      tmp_line[12] = [cargo_request[:bh_m].to_s,cargo_request[:bh_s].to_s]
      tmp_line[13] = [cargo_request[:sl_m].to_s,cargo_request[:sl_s].to_s]
      tmp_line[14] = [cargo_request[:bl_m].to_s,cargo_request[:bl_s].to_s]
      tmp_line[15] = [cargo_request[:lf_m].to_s,cargo_request[:lf_s].to_s]
      tmp_line[16] = [cargo_request[:sc_m].to_s,cargo_request[:sc_s].to_s]
      tmp_line[17] = cargo_request[:ot_m].to_s
      tmp_line[18] = cargo_request[:hs_w].to_s
      tmp_line[19] = cargo_request[:wk_w].to_s
      tmp_line[20] = cargo_request[:i_time]&.strftime("%H:%M") || ""
      tmp_line[21] = []

      # 備考欄の値  *tmp_line[27]
      [%i(hd_w db_w hs_w sn_w eg_w ot_w),%i(note)].each do |symbol_ary|
        tmp_ary = []
        symbol_ary.each do |key|
          prefix = key==:note ? "" : "#{Pdf::SagyoRequestsPdf::OneCharIdentifier[key]}:"
          tmp_ary << "#{prefix}#{cargo_request[key]}" if cargo_request[key].present? && cargo_request[key] != 0
        end
        tmp_line[21] << tmp_ary.join(" ")
      end
    end

    align_settings = {0=>:right,1=>:left,2=>:left,3=>:left,4=>:right,6=>:left,18=>:right,19=>:right,21=>:left}
    text_direction__settings = {11=>1,12=>1,13=>1,14=>1,15=>1,16=>1}
    cnt = 0
    tmp_line.zip(size) do |value,size|
      # 0を空文字に補完
      value = "" if value=="0"
      value = value.map{|v| v=="0" ? "" : v} if value.instance_of?(Array)
      
      align = align_settings[cnt] || :center
      text_direction = text_direction__settings[cnt] || 0
      put_cell(
        pos: [current_pos_x,current_pos_y],
        size: [size*cell_width, Pdf::SagyoRequestsPdf::BodyRowHeight],
        text: value,
        offset:align==:center ? 0 : 2,
        voffset:0.5,
        align: align,
        text_direction:text_direction
      )
      current_pos_x = current_pos_x + size*cell_width
      cnt +=1

    end

    #-- matterの書き込み
    if cargo_request && (cargo_request[:matter1].present? || cargo_request[:matter2].present?)
      @matters_list << [cargo_request[:matter1],[(cell_width*size[0..6].sum) +2,current_pos_y-(DefFontSizeB*2)],'ffffff']
      @matters_list << [cargo_request[:matter2],[(cell_width*size[0..6].sum) +2,current_pos_y-(DefFontSizeB*3)],'ffffff']
    end
  end

  
  def drow_table_footer(values,size)
    one_width = @max_width / size.sum
    current_pos_x = 0
    current_pos_y = @pdf.cursor
    text_direction_settings = {11=>1,12=>1,13=>1,14=>1,15=>1,16=>1}
    put_cell(
      pos: [0,@pdf.cursor],
      size: [@max_width, 2]
    )
    cnt = 0
    values.zip(size).each do |value,size|
      text_direction = text_direction_settings[cnt] || 0
      value = "" if value=="0"
      value = value.map{|v| v=="0" ? "" : v} if value.instance_of?(Array)
      put_cell(
        pos: [current_pos_x,current_pos_y],
        size: [size*one_width, Pdf::SagyoRequestsPdf::HeaderRowHeight],
        text: value,
        align: :center, 
        valign: :center, 
        text_direction:text_direction
      )
      current_pos_x = current_pos_x + size*one_width
      cnt +=1
    end
    @body_under = @pdf.cursor
  end

  def stroke_sepalate_line()
    bcolumn_size = [24,2,2,2,2,2,10] # カラム幅の比率
    cell_width = @max_width / bcolumn_size.sum
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




  #== 描画関係　汎用関数
  def put_cell(pos:,size:,text:"",text_direction:0,font_size:DefFontSizeB,align: :left,valign: :top,offset:0,voffset:0,overflow: :ellipsis,bg_color:nil)
    if bg_color
      @pdf.fill_color bg_color
      @pdf.fill_rectangle(pos, size[0], size[1])
      @pdf.fill_color '000000'
    end
    @pdf.bounding_box(pos, width: size[0], height: size[1], overflow: overflow ) do
      text = [text] unless text.instance_of?(Array)

      # text_dirction: 0->textが配列の場合、縦に配置　　1->textが配列の場合、横に配置
      if text_direction == 1
        inner_width = size[0]/text.length
        text.each.with_index do |value, index|
          at_x = 0 + inner_width * index
          at_x += offset if align==:left
          at_y = size[1] - (voffset * font_size)
          @pdf.text_box value,
                    size: font_size,
                    at: [at_x,at_y],  # 左下が基準　＝＞[0,0]ボックスの左下
                    width: inner_width - offset, 
                    height: size[1], 
                    align: align, 
                    # style: font_style,
                    valign: valign, 
                    overflow: :visible #
        end
      else
        text.each.with_index do |value, index|
          @pdf.text_box value,
                    size: font_size,
                    at: [align==:left ? offset : 0, size[1] - (index + voffset) * font_size],  # 左下が基準　＝＞[0,0]ボックスの左下
                    width: size[0]-offset, 
                    height: size[1], 
                    align: align, 
                    # style: font_style,
                    valign: valign, 
                    overflow: :visible #
        end
      end
      @pdf.transparent(1) { @pdf.stroke_bounds }
    end
  end

  
  def put_text(text:"",pos:,size:nil,font_size:DefFontSizeB,align: :left,valign: :top,overflow: :visible,bg_color:nil)
    text = text.join(" ") if text.instance_of?(Array)
    size = [(font_size*1.0) * (text.length),DefFontSizeB] unless size
    if bg_color
      @pdf.fill_color bg_color
      @pdf.fill_rectangle(pos, size[0], size[1])
      @pdf.fill_color '000000'
    end
    @pdf.text_box text,
              size: font_size,
              at: pos,  # 左下が基準　＝＞[0,0]ボックスの左下
              width: size[0], 
              height: size[1], 
              align: align, 
              valign: valign, 
              overflow: overflow #
  end
end

