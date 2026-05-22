# coding: utf-8

#
#=== 抽象チェックモジュール
# 各クラスでincludeして利用する
#=== Abstract Check Module
# Include and use in each class
module Common::Check
  #
  #=== 数値チェック Numerical check
  # 引数 :: str String 値
  # :: nil_ok Booleam Null可否
  # 戻り値 ::　Booleam (True=OK,False=NG)
  # Arguments :: str String value
  # :: nil_ok Boolean Nullability
  # Return value :: Boolean (True=OK, False=NG)
  def chk_hankaku_suji(str, nil_ok = true)
    if str.blank? && nil_ok
      return true
    end
    if /^[0-9]+$/ =~ str
      true
    else
      false
    end
  end
  #
  #=== 数値チェック(マイナス可)
  # 引数 :: str String 値
  # :: nil_ok Booleam Null可否
  # 戻り値 ::　Booleam (True=OK,False=NG)
  #=== Numeric check (negative values ​​allowed)
  # Argument :: str String value
  # :: nil_ok Boolean Nullity allowed/not allowed
  # Return value :: Boolean (True=OK, False=NG)
  def chk_hankaku_suji_n(str, nil_ok = true)
    if str.blank? && nil_ok
      return true
    end
    if /^\-?[0-9]+$/ =~ str
      true
    else
      false
    end
  end
  #
  #=== 数値チェック(マイナス、小数可)
  # 引数 :: str String 値
  # :: nil_ok Booleam Null可否
  # 戻り値 ::　Booleam (True=OK,False=NG)
  #=== Numeric check (negative and decimal numbers allowed)
  # Argument :: str String value
  # :: nil_ok Boolean Nullness allowed/not allowed
  # Return value :: Boolean (True=OK, False=NG)
  def chk_hankaku_suji_f(str, nil_ok = true)
    if str.blank? && nil_ok
      return true
    end
    if /^(0|\-?[1-9]\d*|\-?(0|[1-9]\d*)\.\d+)$/ =~ str
      true
    else
      false
    end
  end
  #
  #=== 半角英字チェック
  # 引数 :: str String 値
  # :: nil_ok Booleam Null可否
  # 戻り値 ::　Booleam (True=OK,False=NG)
  #=== Checks for half-width English characters
  # Argument :: str String value
  # :: nil_ok Boolean Nullness allowed
  # Return value :: Boolean (True=OK, False=NG)
  def chk_hankaku_eiji(str, nil_ok = true)
    if str.blank? && nil_ok
      return true
    end
    if /^[A-Za-z]+$/ =~ str
      true
    else
      false
    end
  end
  #
  #=== 半角英数字チェック
  # 引数 :: str String 値
  # :: nil_ok Booleam Null可否
  # 戻り値 ::　Booleam (True=OK,False=NG)
  #=== Check for half-width alphanumeric characters
  # Argument :: str String value
  # :: nil_ok Boolean Nullness allowed
  # Return value :: Boolean (True=OK, False=NG)
  def chk_hankaku_eisuji(str, nil_ok = true)
    if str.blank? && nil_ok
      return true
    end
    if /^[0-9A-Za-z ]+$/ =~ str
      true
    else
      false
    end
  end
  #
  #=== 半角英数字+記号（-,_）チェック
  # 引数 :: str String 値
  # :: nil_ok Booleam Null可否
  # 戻り値 ::　Booleam (True=OK,False=NG)
  #=== Checks for alphanumeric characters and symbols (-, _)
  # Argument :: str String value
  # :: nil_ok Boolean Null allowed/not allowed
  # Return value :: Boolean (True=OK, False=NG)
  def chk_hankaku_eisuji_x(str, nil_ok = true)
    if str.blank? && nil_ok
      return true
    end
    if /^[0-9A-Za-z ,_\-@]+$/ =~ str
      true
    else
      false
    end
  end
  #
  #=== 半角英数字+記号（-,_.~:@\/）チェック
  # 引数 :: str String 値
  # :: nil_ok Booleam Null可否
  # 戻り値 ::　Booleam (True=OK,False=NG)
  #=== Checks for alphanumeric characters and symbols (-,_.~:@\/)
  # Argument :: str String value
  # :: nil_ok Boolean Null allowed/not allowed
  # Return value :: Boolean (True=OK, False=NG)
  def chk_hankaku_eisuji_xx(str, nil_ok = true)
    if str.blank? && nil_ok
      return true
    end
    if /^[0-9A-Za-z ,\-_\.\~:@\\\/\/]+$/ =~ str
      true
    else
      false
    end
  end
  #
  #=== 半角英数字+記号（#）チェック
  # 引数 :: str String 値
  # :: nil_ok Booleam Null可否
  # 戻り値 ::　Booleam (True=OK,False=NG)
  #=== Checks for alphanumeric characters and symbols (#)
  # Argument :: str String value
  # :: nil_ok Boolean Nullability
  # Return value :: Boolean (True=OK, False=NG)
  def chk_hankaku_eisuji_color(str, nil_ok = true)
    if str.blank? && nil_ok
      return true
    end
    if /^[0-9A-Za-z\#]+$/ =~ str
      true
    else
      false
    end
  end
  #
  #=== 全角ひらがなチェック
  # 引数 :: str String 値
  # :: nil_ok Booleam Null可否
  # 戻り値 ::　Booleam (True=OK,False=NG)
  #=== Full-width Hiragana Check
  # Argument :: str String Value
  # :: nil_ok Boolean Nullability
  # Return Value :: Boolean (True=OK, False=NG)
  def chk_zenkaku_hiragana(str, nil_ok = true)
    if str.blank? && nil_ok
      return true
    end
    if /^[ぁ-ん]+$/ =~ str
      true
    else
      false
    end
  end
  #
  #=== メールアドレスチェック
  # 引数 :: str String 値
  # :: nil_ok Booleam Null可否
  # 戻り値 ::　Booleam (True=OK,False=NG)
  #=== Email Address Check
  # Argument :: str String Value
  # :: nil_ok Boolean Null OK/NG
  # Return Value :: Boolean (True=OK, False=NG)
  def chk_format_mail(str, nil_ok = true)
    if str.blank? && nil_ok
      return true
    elsif str.blank?
      return false
    end
    tmpdata=str.split(';')
    tmpdata.each do |tmpstr|
      if /^[ -~｡-ﾟ]*$/ =~ tmpstr && /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i =~ tmpstr
      else
        return false
      end
    end
    return true
  end
  #
  #=== URLチェック
  # 引数 :: str String 値
  # :: nil_ok Booleam Null可否
  # 戻り値 ::　Booleam (True=OK,False=NG)
  #=== URL check
  # Argument :: str String value
  # :: nil_ok Boolean Nullness allowed
  # Return value :: Boolean (True=OK, False=NG)
  def chk_format_uri(str, nil_ok = true)
    if str.blank? && nil_ok
      return true
    elsif str.blank?
      return false
    end
#    begin
#      uri = URI.split(str)
#      return (uri.first == 'http' or uri.first == 'https')
#    rescue
#      return false
#    end
  end
  #
  #=== 電話番号チェック
  # 引数 :: str String 値
  # :: nil_ok Booleam Null可否
  # 戻り値 ::　Booleam (True=OK,False=NG)
  #=== Phone number check
  # Argument :: str String value
  # :: nil_ok Boolean Null allowed/not allowed
  # Return value :: Boolean (True=OK, False=NG)
  def chk_format_tel(str, nil_ok = true)
    if str.blank? && nil_ok
      return true
    end
    if /^[0-9\-]+$/ =~ str
      true
    else
      false
    end
  end
  #
  #=== 電話番号厳密チェック
  # 引数 :: str String 値
  # :: nil_ok Booleam Null可否
  # 戻り値 ::　Booleam (True=OK,False=NG)
  #=== Strict phone number check
  # Argument :: str String value
  # :: nil_ok Boolean Null allowed/not allowed
  # Return value :: Boolean (True=OK, False=NG)
  def chk_format_tel_strict(str, nil_ok = true)
    if str.blank? && nil_ok
      return true
    end
    if /^\d{2,5}-\d{1,4}-\d{4}$/ =~ str
      true
    else
      false
    end
  end
  #
  #=== 固定電話番号チェック
  # 引数 :: str String 値
  # :: nil_ok Booleam Null可否
  # 戻り値 ::　Booleam (True=OK,False=NG)
  #=== Checks landline phone number
  # Argument :: str String value
  # :: nil_ok Boolean Null allowed/not allowed
  # Return value :: Boolean (True=OK, False=NG)
  def chk_format_tel_fixed(str, nil_ok = true)
    if str.blank? && nil_ok
      return true
    end
    if /^\d{3}-\d{3}-\d{4}$/ =~ str || /^\d{2}-\d{4}-\d{4}$/ =~ str
      true
    else
      false
    end
  end

  #
  #=== 日付チェック
  # 引数 :: str String 値
  # :: nil_ok Booleam Null可否
  # 戻り値 ::　Array [Booleam (True=OK,False=NG) , 整形後の日付文字列(%Y/%m/%d)]
  #=== Date Check
  # Argument :: str String value
  # :: nil_ok Boolean Nullability
  # Return Value :: Array [Booleam (True=OK, False=NG) , Formatted Date String (%Y/%m/%d)]
  def chk_format_date(str, nil_ok = true)
    if str.blank? && nil_ok
      return [true,'']
    end
    flag = true
    retstr=""
    begin
      case str.length
      when 6
        yy = 2000 + str[0..1].to_i
        mm = str[2..3].to_i
        dd = str[4..5].to_i
      when 8,9
        tmp = str.split('/')
        if tmp.length==3
          yy = tmp[0].to_i
          mm = tmp[1].to_i
          dd = tmp[2].to_i
        else
          tmp = str.split('-')
          if tmp.length==3
            yy = tmp[0].to_i
            mm = tmp[1].to_i
            dd = tmp[2].to_i
          else
            yy = str[0..3].to_i
            mm = str[4..5].to_i
            dd = str[6..7].to_i
          end
        end
      when 10
        yy = str[0..3].to_i
        mm = str[5..6].to_i
        dd = str[8..9].to_i
      end
      if Date.valid_date?(yy,mm ,dd) and yy > 0
        retstr=Date.new(yy, mm, dd).strftime("%Y/%m/%d")
      else
        flag = false
      end
    rescue
      flag = false
    end

    return [flag,retstr]
  end
  #
  #=== 時間チェック
  # 引数 :: str String 値
  # :: nil_ok Booleam Null可否
  # 戻り値 ::　Array [Booleam (True=OK,False=NG) , 整形後の時間文字列（%H:%M）]
  #=== Time Check
  # Argument :: str String value
  # :: nil_ok Boolean Nullability
  # Return Value :: Array [Booleam (True=OK, False=NG), Formatted Time String (%H:%M)]
  def chk_format_time(str, nil_ok = true)
    if str.blank? && nil_ok
      return [true,'']
    end
    flag = true
    retstr=''
    begin
      tmp=str.scan(/(-?\d{1,2}):(-?\d{1,2})/)
      unless tmp.size == 1
        tmp=str.scan(/(\d{2})(\d{2})/)
      end
      if tmp.size ==1
        hh = tmp[0][0].to_i
        ii = tmp[0][1].to_i
        if hh <0 || hh>23 || ii<0  || ii>59
          flag = false
        else
          retstr="#{'%02d' % hh}:#{'%02d' % ii}"
        end
      else
        flag = false
      end
    rescue
      flag = false
    end
    return [flag,retstr]
  end
  #
  #=== 日付時間チェック
  # 引数 :: str String 値
  # :: nil_ok Booleam Null可否
  # 戻り値 ::　Array [Booleam (True=OK,False=NG) , 整形後の日付時間文字列（%Y/%m/%d %H:%M）]
  #=== Date and Time Check
  # Argument :: str String Value
  # :: nil_ok Boolean Nullability
  # Return Value :: Array [Booleam (True=OK, False=NG) , Formatted Date and Time String (%Y/%m/%d %H:%M)]
  def chk_format_datetime(str, nil_ok = true)
    if str.blank? && nil_ok
      return [true,'']
    elsif str.blank?
      return [false,'']
    end
    flag = false
    retstr = ''
    tmp = str.split(' ')
    if tmp.length==2
      d_ck = chk_format_date(tmp[0])
      t_ck = chk_format_time(tmp[1])
      flag = d_ck[0] && t_ck[0]
      retstr = "#{d_ck[1]} #{t_ck[1]}" if flag
    end
    return [flag,retstr]
  end
  #
  #=== 時間期間チェック
  # 引数 :: str String 値
  # :: nil_ok Booleam Null可否
  # 戻り値 ::　Array [Booleam (True=OK,False=NG) , 整形後の日付時間文字列（%Y/%m/%d %H:%M）]
  #=== Time Period Check
  # Argument :: str String Value
  # :: nil_ok Boolean Nullability
  # Return Value :: Array [Booleam (True=OK, False=NG) , Formatted Date and Time String (%Y/%m/%d %H:%M)]
  def chk_format_time_term(str, nil_ok = true)
    if str.blank? && nil_ok
      return true
    end
    if /^\d{2}:\d{2}-\d{2}:\d{2}$/ =~ str
      true
    else
      false
    end
  end

  #
  #=== CSVデータのチェック Check CSV data
  def chk_csv_datas(fobj,len_ch=true)
    ret = {:cd=>true,:msg=>"",:counts=>{:T=>0,:I=>0,:U=>0,:E=>0}}
    #ファイルサイズチェック File size check
    if (fobj.blank? or fobj.size < 1)
      ret[:msg] << I18n.t("system_errors.file_null")
      ret[:cd] = false
    elsif fobj.size > MAX_FILE_SIZE
      ret[:msg] << I18n.t("system_errors.file_size",:max_size=>MAX_FILE_SIZE_MB)
      ret[:cd] = false
    else
      require 'kconv'
      paramkey = getparamkey()
      param = getparams()
      data = fobj.read
      reader = CSV.parse(data)
      reader.shift        #1行目を読み飛ばし Skip the first line
      ret[:counts][:T] += 1
      reader.each do |datas|
        ret[:counts][:T] += 1
        #CSVデータをチェックする Check the CSV data.
        retmsg = ""
        if paramkey.length < datas.length && len_ch
          retmsg = I18n.t("system_errors.csv_format")
        else
          datacount = 0
          paramkey.each do |key|
            val = datas[datacount]
            val = val.kconv(Kconv::UTF8,Encoding::CP932).chomp unless val.blank?
            case param[key]["type"]
            when "file","view"
              #CSVでファイルはチェックしない
              #反映時はスキップ注意
              # Do not check the file in CSV format
              # Be careful to skip when updating
            else
              retck = checkdata(param[key],val)
              unless retck[0].nil?
                retmsg << "#{retck[0]}<br />\n"
              end
            end
            datacount += 1
          end
        end
        unless retmsg==""
          ret[:msg] << "#{I18n.t("system_errors.csv_validate",**{:row=>ret[:counts][:T],:msg=>retmsg})}<br />\n"
          ret[:cd] = false
          ret[:counts][:E] += 1
        end
        if ret[:counts][:E] > 9
          ret[:msg] << "#{I18n.t("system_errors.csv_ck_over")}<br />\n"
          break
        end
      end
    end
    return ret
  end
end