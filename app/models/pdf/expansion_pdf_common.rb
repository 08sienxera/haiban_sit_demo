#= Pdf::PdfCommonを継承
#カスタマイズ性の高い描画機能を追加 Added highly customizable drawing function
class Pdf::ExpansionPdfCommon < Pdf::PdfCommon

  # 標準フォントサイズ（ヘッダ） Standard font size (header)
  DefFontSizeH = 7 
  # 標準フォントサイズ（ボディ） Standard font size (body)
  DefFontSizeB = 9

  # 初期設定 Initial settings
  def initialize(cd,page_condition = {},name:nil)
    super(cd,page_condition)
    @name = name if name
  end

  # 出力ファイル名を返す return output file name
  def name()
    return @name || @filename
  end


  private
  #== 描画関係　汎用関数 Drawing-related general-purpose functions
  def set_grid(x_size:,y_size:,width:,height:,at:)
    @start_at = at
    @grid_width = width
    @grid_height = height
    @grid_width_one = width / x_size
    @grid_height_one = height / y_size
    @grid_x_positions = []
    @grid_y_positions = []
    (x_size+1).times do |n|
      pos_x = at[0] + (@grid_width_one * n)
      @grid_x_positions << pos_x
    end
    (y_size+1).times do |n|
      pos_y = (at[1]-height) + (@grid_height_one * n)
      @grid_y_positions << pos_y
    end
    @grid_y_positions.reverse!
  end
  
  def get_grid_info
    return {
      start_at: @start_at,
      grid_width: @grid_width,
      grid_height: @grid_height,
      grid_width_one: @grid_width_one,
      grid_height_one: @grid_height_one,
      grid_x_positions: @grid_x_positions,
      grid_y_positions: @grid_y_positions,
    }
  end
  
  def put_grid(value:,pos:,line_weight:nil,font_size:DefFontSizeB,bg_color:nil)
    pos_at = [@grid_x_positions[pos[0][0]],@grid_y_positions[pos[0][1]]]
    width = @grid_x_positions[pos[1][0]] - @grid_x_positions[pos[0][0]]
    height = @grid_y_positions[pos[0][1]] - @grid_y_positions[pos[1][1]]
    put_cell(pos:pos_at,size:[width,height],text:value,align: :center,valign: :center,line_weight:line_weight,font_size:font_size,bg_color:bg_color)
  end

  def put_cell(pos:,size:,text:"",text_direction:0,font_size:DefFontSizeB,align: :left,valign: :center,offset:0,voffset:0,overflow: :ellipsis,bg_color:nil,font_color:nil,line_weight:nil,multiple_text_reverse:false)
    def_color = @pdf.fill_color
    if bg_color
      @pdf.fill_color bg_color
      @pdf.fill_rectangle(pos, size[0], size[1])
      @pdf.fill_color def_color
    end
    @pdf.bounding_box(pos, width: size[0], height: size[1], overflow: overflow ) do
      text = [text] unless text.instance_of?(Array)

      # text_dirction: 0->textが配列の場合、縦に配置　　1->textが配列の場合、横に配置 | text_direction: 0->If text is an array, place it vertically 1->If text is an array, place it horizontally
      if text_direction == 1
        draw_horizontal_text(text, size, offset, voffset, font_size, align, valign, font_color)
      else
        draw_vertical_text(text, size, offset, voffset, font_size, align, valign, font_color,multiple_text_reverse:multiple_text_reverse)
      end

      @pdf.transparent(1) {
        def_line = @pdf.line_width
        @pdf.line_width = line_weight if line_weight
        @pdf.stroke_bounds 
        @pdf.line_width = def_line
      }
    end
  end
  
  def put_text(text:"",pos:,size:nil,font_size:DefFontSizeB,align: :left,valign: :top,overflow: :visible,bg_color:nil,font_color:nil,style:nil)
    text = text.join(" ") if text.instance_of?(Array)
    size = [(font_size*1.0) * (text.length),font_size] unless size
    if bg_color
      def_color = @pdf.fill_color
      begin
        @pdf.fill_color bg_color
      rescue 
        @pdf.fill_color "ffffff"
      end
      
      @pdf.fill_rectangle(pos, size[0], size[1])
      @pdf.fill_color def_color
    end
    
    def_f_color = @pdf.fill_color
    @pdf.fill_color font_color if font_color
    if style == :bold
      l = 0.02
      posses = [[pos[0]+l,pos[1]],[pos[0]-l,pos[1]],[pos[0],pos[1]+l],[pos[0],pos[1]-l]]
    else
      posses = [pos]
    end
    posses.each do |pos|
      @pdf.text_box text,
                size: font_size,
                at: pos,  # 左下が基準　＝＞[0,0]ボックスの左下 | Bottom left is the reference => Bottom left of the [0,0] box
                width: size[0], 
                height: size[1], 
                align: align, 
                valign: valign
    end
    @pdf.fill_color def_f_color
  end


  private 
  def draw_horizontal_text(text, size, offset, voffset, font_size, align, valign, font_color)
    def_color = @pdf.fill_color
    inner_width = size[0]/text.length
    text.each.with_index do |value, index|
      at_x = 0 + inner_width * index
      at_x += offset if align==:left
      at_y = size[1] + (voffset * font_size) * -1

      @pdf.fill_color font_color if font_color
      @pdf.text_box value,
                size: font_size,
                at: [at_x,at_y],  # 左下が基準　＝＞[0,0]ボックスの左下 | Bottom left is the reference => Bottom left of the [0,0] box
                width: inner_width - offset, 
                height: size[1], 
                align: align, 
                valign: valign, 
                overflow: :visible #
      @pdf.fill_color def_color
    end
  end

  
  def draw_vertical_text(text, size, offset, voffset, font_size, align, valign, font_color,multiple_text_reverse:false)
    def_color = @pdf.fill_color
    if font_size*text.length>size[1]
      height = font_size
    else
      height = size[1]/text.length
    end
    text.each.with_index do |value, index|
      @pdf.fill_color font_color if font_color
      @pdf.text_box value,
                size: font_size,
                at: [align==:left ? offset : 0, size[1] - (index + voffset) * font_size],  # 左下が基準　＝＞[0,0]ボックスの左下 | Bottom left is the reference => Bottom left of the [0,0] box
                width: size[0]-offset, 
                height: height, 
                align: align, 
                valign: valign, 
                overflow: :visible #
      @pdf.fill_color def_color
      if multiple_text_reverse
        if align==:left
          align=:right
        elsif align==:right
          align=:left
        end
      end
    end
  end
end

