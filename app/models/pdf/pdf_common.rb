# coding: utf-8

#--
#***************************************************************************
#*     ｼｽﾃﾑ名    ：
#*     ｻﾌﾞｼｽﾃﾑ名 ：    PDF出力共通クラス
#*     注意      ：    日本語フォントが必要
#*     作成      ：    2014/01/30 SEIKO
#*     変更	：
#***************************************************************************
#++
#-- 
#******************************************************************************** 
#* System name: 
#* Subsystem name: PDF output common class 
#* Note: Japanese font required 
#* Created: 2014/01/30 SEIKO 
#* Change: 
#******************************************************************************** 
#++

#= PDF出力共通クラス | PDF output common class
class Pdf::PdfCommon
  require "prawn"
  include Common::Format
  include ApplicationHelper
  #フォント（ヘルベチカ） | Font (Helvetica)
  FONT_A = "Helvetica"
  #フォント(明朝) | Font (Mincho)
  FONT_M = "vendor/fonts/ipaexm.ttf"
  #フォント(ゴシック) | Font (Gothic)
  FONT_G = "vendor/fonts/ipaexg.ttf"

  #初期設定 | Initial settings
  def initialize(cd,page_condition = {})
    unless File.exist?(PDF_OUT_DIR)
      Dir::mkdir(PDF_OUT_DIR,0755)
    end
    @filename = "#{Time.now.strftime("%Y%m%d%H%M%S")}_#{cd}.pdf"
    @filepath="#{PDF_OUT_DIR}/#{@filename}"
    def_page_condition = {
      :page_size => 'A4',
      :page_layout => :portrait,  # 用紙向き ( 縦:portrait、横:landscape ) | Paper orientation (portrait, landscape)
      :top_margin => 40,
      :bottom_margin => 30,
      :left_margin => 20,
      :right_margin => 20}
    @page_condition = def_page_condition.merge(page_condition)
    @pdf = Prawn::Document.new(@page_condition)
    @pdf.font(FONT_M)
    @page_w = @pdf.bounds.right
    @page_h = @pdf.bounds.height
  end
  #PDFを保存し後始末 | Save the PDF and clean up afterwards
  def fin()
   @pdf.render_file(@filepath)         #ファイルへ書き込む | write to file
   @pdf = nil
   return @filepath
  end
  #改ページ | page break
  def start_new_page(page_condition = {})
    @pdf.start_new_page(@page_condition.merge(page_condition))
  end
  #縦を引く | draw vertically
  def v_line(x,y,l,width = 1)
    def_line = @pdf.line_width
    @pdf.line_width = width
    @pdf.stroke_color("000000")
    @pdf.line([x, y], [x, (y-l)])
    @pdf.stroke
    @pdf.line_width = def_line
  end
  #アンダーラインを引く | draw an underline
  def u_line(x,y,w,width = 1)
    def_line = @pdf.line_width
    @pdf.line_width = width
    @pdf.stroke_color("000000")
    @pdf.line([x, y], [(x + w), y])
    @pdf.stroke
    @pdf.line_width = def_line
  end
  #Box
  def box(x,y,txt,options={},w=nil,h=nil)
    w = @pdf.width_of(txt)+2 if h.nil?
    h = @pdf.height_of(txt)+2 if h.nil?
    @pdf.bounding_box([x, y], :width => w, :height => h){
      @pdf.text(txt,options)
      @pdf.transparent(1) { @pdf.stroke_bounds }
    }
  end
end
