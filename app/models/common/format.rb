# coding: utf-8

#
#=== 抽象フォーマットモジュール
# 各クラスでincludeして利用する
#=== Abstract Format Module
# Include and use in each class
module Common::Format
  #
  #=== 数値- の半角→全角文字への置換
  # 引数 :: str String 値
  # 戻り値 ::　String 変換後の文字列
  #=== Replace half-width hyphens with full-width characters
  # Arguments :: str String value
  # Return value :: String converted string
  def h2z(str)
    str = str.to_s unless str.is_a?(String)
    retstr=str.tr('0123456789-','０１２３４５６７８９－') unless str.blank?
    return retstr
  end
  #
  #=== 文字列日付(yyyy/mm/dd)→日付オブジェクトの変換
  # 引数 :: str String 値
  # 戻り値 ::　Date 日付オブジェクト
  #=== Converts a string date (yyyy/mm/dd) to a date object
  # Arguments :: str String value
  # Return value :: Date Date object
  def to_dateobj(str)
    retobj = nil
    case str.class.to_s
    when "Date"
      return str
    when "Time"
      return Date.strptime(str.strftime("%Y/%m/%d"), "%Y/%m/%d")
    when "String"
      tmp = str.split(/\s*\/\s*/)
      begin
        retobj = Date::new(tmp[0].to_i,tmp[1].to_i,tmp[2].to_i)
      rescue
        retobj = nil
      end
    end
    return retobj
  end
  #
  #=== 全角→半角文字への置換
  # 引数 :: str String 値
  # 戻り値 ::　String 変換後の文字列
  #=== Full-width character to half-width character replacement
  # Argument :: str String value
  # Return value :: String converted string
  def em2half(str)
    retstr=str.tr('ａ-ｚＡ-Ｚ０-９','a-zA-Z0-9').upcase if str.class.to_s == "String"
    return retstr
  end
  #カンマ編集
  #Edit comma
  def money_format(num)
    if num.is_a?(Integer)
      strnum = num.to_s
    elsif num.is_a?(String)
      strnum = num
    end
    return (strnum =~ /[-+]?\d{4,}/) ? (strnum.reverse.gsub(/\G((?:\d+\.)?\d{3})(?=\d)/, '\1,').reverse) : num
  end
  #お金単位追加
  #Add money unit
  def money_unit(num,locale=nil)
    locale = Common::Func.get_locale if locale.nil?
    minus = (num.to_i < 0 ? "-":"")
    strnum = minus+money_format(num.to_s.scan(/\d+/).join)
    case locale
    when :ja,"ja" ; return "#{strnum}円"
    when :en,"en" ; return "JPY #{strnum}"
    else          ; return strnum
    end
  end
  #
  #=== 文字列の途中カット
  # 引数 :: str String 値
  # ::vmaxlength　Int　表示文字数
  # 戻り値 ::　String 先頭からvmaxlength文字までのの文字列
  #=== Cut a string midway
  # Argument :: str String value
  # ::vmaxlength Int Number of characters to display
  # Return value :: String String from the beginning up to vmaxlength characters
  def str_cut(str,vmaxlength = nil,bwd= "...")
    if str.class.to_s == "String"
      retstr = str
      unless vmaxlength.nil?
        if str.split(//u).length > vmaxlength
          retstr = "#{str.split(//u)[0..vmaxlength-1].join}#{bwd}"
        end
      end
    else
      retstr = str.to_s
    end
    return retstr
  end
  #
  #=== パスワード生成(ランダム英数字)
  # 引数 :: len Integer 生成する文字列の長さ
  #=== Password generation (random alphanumeric characters)
  # Arguments :: len Integer Length of the string to generate
  def mk_password(len = 8)
    str_array = ("a".."z").to_a + ("A".."Z").to_a + ("2".."9").to_a + ["-","_","@"]
    %w[o l O ].each{|delstr| str_array.delete(delstr)}
    ret_a = str_array.shuffle[0..(len-1)]
    loop_count = 0
    while ret_a.first =~ /\-|\_|@/ do
      tmp = ret_a.first
      ret_a.shift
      ret_a.push(tmp)
      loop_count += 1
      ret_a.unshift("x") if loop_count > len
    end
    return ret_a.join
  end
  #
  #=== 数字のリスト生成
  # 引数 :: s　integer　開始
  #     :: e　integer　終了
  #     :: listin　Hash　制御データ
  #=== Generate a list of numbers
  # Arguments :: s integer start
  # :: e integer end
  # :: listin Hash control data
  def get_numlist(s,e,listin={})
    retlist=[]
    listin[:type]='array' if listin[:type].nil?
    listin[:format]='%02d' if listin[:format].nil?
    listin[:step]=1 if listin[:step].nil?
    case listin[:type]
    when 'array'
      retlist << [listin[:all],''] unless listin[:all].nil?
      s.step(e,listin[:step]){|wi|
        tmp = format(listin[:format],wi)
        retlist << [tmp,tmp]}
    when 'hash'
      retlist={}
      retlist[''] =listin[:all] unless listin[:all].nil?
      s.step(e,listin[:step]){|wi|
        tmp = format(listin[:format],wi)
        retlist[tmp] = tmp}
    end
    return retlist
  end
  #
  #=== 日付のリスト生成
  # 引数 :: s　Date　開始
  #     :: e　Date　終了
  #     :: listin　Hash　制御データ
  #=== Generate a list of dates
  # Arguments :: s Date Start
  # :: e Date End
  # :: listin Hash Control data
  def get_daylist(s,e,listin={})
    retlist=[]
    listin[:type]='array' if listin[:type].nil?
    listin[:format]='%m/%d' if listin[:format].nil?
    case listin[:type]
    when 'array'
      retlist << [listin[:all],''] unless listin[:all].nil?
      w = s
      while w <= e
        retlist << [w.strftime(listin[:format]),w]
        w += 1
      end
    when 'hash'
      retlist={}
      retlist[''] = listin[:all] unless listin[:all].nil?
      w = s
      while w <= e
        retlist[w] = w.strftime(listin[:format])
        w += 1
      end
    end
    return retlist
  end
  #日付時間のフォーマット date time format
  def setftime_td(s,format)
    begin
      if s.is_a?(Time) || s.is_a?(Date)
        return s.strftime(format)
      elsif s.is_a?(String)
        tmp = Time.parse(s)
        return tmp.strftime(format)
      end
    rescue
      return s.to_s
    end
  end
  #日付時間のフォーマット date time format
  def setftime(s,format)
    begin
      return s.strftime(format)
    rescue
      return s
    end
  end
  #Listから文字列を取得する Get string from List
  def list2str(list,cd)
    list.each{|txt,lcd| return txt if lcd == cd.to_s} unless list.blank?
    return cd
  end
  #N進数文字列の取得
  #num:変換元数字
  #str_array:文字列配列
  #digit:最大桁数
  #Getting a number string in base N
  #num: Source digit
  #str_array: String array
  #digit: Maximum number of digits
  def n_decimal(num,str_array,digit=4)
    ret = []
    asize = str_array.size
    r = num
    digit.downto(2){|d|
      f = asize ** (d - 1 )
      q = r / f
      r = r % f
      q = q % asize if q >= asize
      ret << str_array[q]
    } if digit > 1 
    ret << str_array[r]
    return ret.join("")
  end

end