# encoding: utf-8
#--
#***************************************************************************
#*     ｼｽﾃﾑ名    ：    
#*     ｻﾌﾞｼｽﾃﾑ名 ：    Excel出力共通クラス
#*     ﾌｧｲﾙ名    ：
#*     ｺﾒﾝﾄ      ：
#*     作成      ：    2011/12/30 SEIKO N.Ooshige
#*     変更	：
#***************************************************************************
#++

#= Excel出力共通クラス 
class Excel::ExcelClass
  require "writeexcel"
  #初期設定
  def initialize(cd,out_dir:FILE_OUT_DIR)
    unless File.exist?(out_dir)
      Dir::mkdir(out_dir,0755)
    end
    @filepath="#{out_dir}/#{Time.now.strftime("%Y%m%d%H%M%S")}_#{cd}.xls"
    @workbook = WriteExcel.new(@filepath)
    @workbook.set_tempdir("#{out_dir}")
    ######################################################
    # 書式を作成
    ######################################################
    #基本
    @font={:font=>"ＭＳ Ｐゴシック",:size=>11,:color=>8,
           :align=>"center",:valign=>"vcenter",:text_wrap=>1,
           :border_color=>8}
#    format[:d]=@workbook.add_format(@font)
#    format[:d_l]=@workbook.add_format(@font.merge({:align=>"left"}))
  end
  #Excelを保存し後始末
  def fin()
   @workbook.close
   @workbook=nil
   return @filepath
   
  end
  #一意のシート名を生成する
  def get_sheet_name(name)
    wk_name = NKF.nkf('-w -X', name).tr("A-Za-z0-9","Ａ-Ｚａ-ｚ０-９").tr('あ-ん', 'ア-ン')
    count = 0
    @workbook.sheets.each{|worksheet|
      if wk_name == worksheet.name.encode("utf-8") || /^#{wk_name}_\d*$/=~ worksheet.name.encode("utf-8")
        count += 1
      end
    }
    return (count == 0 ? "#{wk_name}" : "#{wk_name}_#{count}")
  end
  #色Indexのテスト
  def test_color_index(worksheet,row,maxno)
    worksheet.set_row(row, 20)
    maxno.times{|wi|
      tmp_form = @workbook.add_format()
      #tmp_form.copy()
      tmp_form.set_bg_color(wi)
      worksheet.write(row,wi,wi,tmp_form)
    }
  end
  #行番号の取得
  def test_col_nos(worksheet,row,maxno)
    maxno.times{|wi|
      worksheet.write(row,wi,wi,@format[:s][:d])
    }
  end
  #文字列の途中カット
  def str_cut(value,vmaxlength)
    return "" if value.blank?
    return value if vmaxlength.blank?
    maxl = vmaxlength.to_i
    val_array = value.split(//u)
    if val_array.length > maxl
      return "#{val_array[0..maxl].join}"
    else
      return value
    end
  end

  #エクセルオブジェクトを返す 
  def excel
    return @workbook
  end

  #エクセルフォーマットオブジェクトを返す
  # 引数
  # align: str  'left','center','right'
  # fcolor,bgcolor: str  エクセルで規定された色
  # fweight: bool  nil,false -> 標準,true -> 太字
  # fsize: int
  # border: bool,integer,array
  # props: ハッシュ形式の初期値
  def get_format(align: nil,fcolor: nil,bgcolor: nil,fweight: nil,fsize: nil,border: nil,props:{})
    ret_format =  @workbook.add_format(props)
    ret_format.set_align(align) if align
    ret_format.set_color(fcolor) if fcolor
    ret_format.set_bg_color(bgcolor) if bgcolor
    ret_format.set_bold if fweight
    ret_format.set_size(fsize) if fsize
    if border.present?
      case border.class.name
      when "TrueClass","FalseClass"
        ret_format.set_border(1)
      when 'Integer'
        ret_format.set_border(border)
      when 'Array'
        case border.size
          when 1
            ret_format.set_border(border[0])
          when 2
            ret_format.set_top(border[0])
            ret_format.set_right(border[1])
            ret_format.set_bottom(border[0])
            ret_format.set_left(border[1])
          when 3
            ret_format.set_top(border[0])
            ret_format.set_right(border[1])
            ret_format.set_left(border[1])
            ret_format.set_bottom(border[2])
          when 4
            ret_format.set_top(border[0])
            ret_format.set_right(border[1])
            ret_format.set_bottom(border[2])
            ret_format.set_left(border[3])
        end
      else
        ret_format.set_border(1)
      end
    end
    ret_format.set_font("ＭＳ Ｐゴシック")
    return ret_format
  end



end
