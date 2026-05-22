# coding: utf-8

#--
#***************************************************************************
#*     ｼｽﾃﾑ名    ：    
#*     ｻﾌﾞｼｽﾃﾑ名 ：    共通クラス
#*     ﾌｧｲﾙ名    ：    
#*     ｺﾒﾝﾄ      ：    
#*     作成      ：    2012/07/27 SEIKO
#*     変更	：    
#***************************************************************************
#++

class Common::CommonClass
  include Common::Check
  include Common::Format

  #コンストラクタ constructor
  def initialize(str)
    @param = Hash.new
    @paramkey = []
    @gname = str
    @other_datas = {}
  end
  #パラメータ設定 Parameter settings
  def setparams(key,datas)
    @param[key]=datas
    @paramkey << key
  end
  #パラメータ設定(個別) Parameter settings (individual)
  def setparam(key1,key2,value)
    @param[key1][key2]=value
    case @param[key1]["type"]
    when "select","radio"
      if key2 == "value" && value != ""
        list = @param[key1]['list']
        case list.class.to_s
        when "Hash"
          unless list.key?(value)
            index = list.key(value)
            @param[key1][key2] = index unless index.nil?
          end
        when "Array"
          if list.select{|tmp| tmp[1]==value}.length==0
            ta = list.select{|tmp| tmp[0]==value}
            unless ta.length==0
              @param[key1][key2]=ta[0][1]
            end
          end
        end
      end
    when "ckeck_list"
      if key2 == "value" && value.present?
        list = @param[key1]['list']
        vals  = value.split(/\s*\|\s*/)
        temp_a = []
        vals.each{|val|
          unless val.blank?
            ta = list.select{|tmp| tmp[0] == val}
            if ta.length == 0
              temp_a << val
            else
              temp_a << ta[0][1]
            end
          end
        }
        @param[key1][key2] = "|#{temp_a.join("|")}|"
      end
    end
  end
  #パラメータ設定 Parameter settings
  def set_all_param(key2,value)
    @paramkey.each do |key|
      setparam(key,key2,value)
    end
  end
  #パラメータ削除 Delete parameter
  def unsetparams(key)
    @param.delete(key)
    @paramkey.delete(key)
  end
  #パラメータデータの全削除 Complete deletion of parameter data
  def unset_all_paramsdata(key)
    @paramkey.each do |pkey|
      @param[pkey].delete(key)
    end
  end
  #gnameの設定 gname settings
  def setgname(str)
    @gname=str
  end
  #パラメータ出力 Parameter output
  def getparams()
    return @param
  end
  #パラメータ出力(個別) Parameter output (individual)
  def getparam(key1)
    ret = ""
    unless @param[key1].nil?
        ret = @param[key1]
    end
    return ret
  end
  #パラメータ出力(個別) Parameter output (individual)
  def getparamdata(key1,key2)
    ret = ""
    if key1.is_a?(Array)
      ret_a = []
      key1.each{|key|ret_a << getparamdata(key,key2)}
      ret = ret_a.join("-")
    else
      if @param[key1].present?
        if @param[key1][key2].present?
          ret = @param[key1][key2]
        elsif key2 == "v_value" && @param[key1]["value"].present?
          ret = @param[key1]["value"]
          if @param[key1]["list"].present?
            ret = list_to_str(key1,ret)
          end
        end
      end
    end
    return ret
  end
  #パラメータデータの全出力 Full output of parameter data
  def get_all_paramsdata(key)
    ret = {}
    @paramkey.each do |pkey|
      unless @param[pkey][key].nil?
        ret[pkey] = @param[pkey][key]
      end
    end
    return ret
  end
  #パラメータのキーリストを返す Returns a list of parameter keys.
  def getparamkey()
    return @paramkey
  end
  #gnameの取得 Get gname
  def getgname()
    return @gname
  end

  #パラメータに指定キーが存在するか返す Returns whether the specified key exists in the parameters.
  def has_key?(key)
    return @param.has_key?(key)
  end
  #順序を変える change order
  def set_index(key,index)
    tmp = @paramkey.slice!(0,index)
    key_index = @paramkey.index(key)
    @paramkey.delete_at(key_index) unless key_index.nil?
    @paramkey = tmp + [key] + @paramkey
  end
  #順序を変える（末尾へ移動） Change the order (move to the end).
  def set_last_index(key)
    @paramkey.delete(key)
    @paramkey << key
  end
  #入力モードかどうか Input mode or not
  def is_input?
    ret = 0
    get_all_paramsdata("inputFlg").each_value{|flg| ret += flg }
    return (ret > 0)
  end


  #DBロード用SQLのSelect文の生成 Generating SQL SELECT statements for database loading
  def mksqlselect()
    retselect = []
    @param.each_pair do |key, palamndata|
      unless palamndata['field'].nil?
        retselect << "#{palamndata['field']} as #{key}"
      else
        retselect << key
      end
    end
    if retselect.length > 0 
      return retselect.join(',')
    else
      return nil
    end
  end
  #DB登録用データの取得 Retrieving data for database registration
  def mksqldata(updateuid,errok=true,rep=nil)
    retdata = Hash.new
    @param.each_pair do |key, palamndata|
      if palamndata['msg'].nil? || errok
        if rep.nil? then sqlkey = key else sqlkey = key.gsub(rep[0],rep[1]) end
        retdata[sqlkey] = palamndata['value']
        case palamndata['sp_option']
        when 'MD5'
          if retdata[sqlkey].length > 20
            retdata.delete(sqlkey)
          else
            retdata[sqlkey] = Digest::MD5.new.update(retdata[sqlkey]).to_s
          end
        when 'no_db'
          retdata.delete(sqlkey)
        end
      end
    end
    retdata['updated_uid']=updateuid
    return retdata
  end

  #検索用にパラメータをSet Set parameters for searching
  def set_serch_params(ccobj)
    @paramkey.concat(ccobj.getparamkey())
    tmpparam = ccobj.getparams()
    tmpparam.each_pair do |key, data|
      unless data['field'].nil? || !data['serch_field'].nil?
        data['serch_field']=data['field']
      end
      case data['type']
      when 'textN','textNN','textD','textT','textDT'
        @param[key] = hash_cp(data)
        @param["#{key}_e"] = hash_cp(data)
        @param["#{key}_e"]["inputFlg"] = 1
      when 'textX','textXX','textA','textAA','textJ','textKn','textKh','textURL'
        @param[key]= hash_cp(data)
        criteria={'title'=>'検索条件','type'=>'select','size'=>'2','maxlength'=>'2','inputFlg'=>1,'essFlg'=>0,'align'=>'C',
          'list'=>[["部分一致","pa"],["前方一致","fr"],["後方一致","bl"],["完全一致","eq"]],
          'defVal'=>'pa'}
        @param["#{key}_cri"]=criteria
      else        
        @param[key]= hash_cp(data)
      end
    end
    set_all_param("inputFlg",1)
    unset_all_paramsdata("defVal")
  end
  #DBロード用(検索)SQLのWhere句の生成 Generating a WHERE clause for SQL queries used for database loading (searching).
  def mksqlwhere(retwhere = [])
    if retwhere[0].nil? then retwhere[0]='' end
    @paramkey.each do |key|
      if @param.has_key?(key)
        palamndata = @param[key]
        next if palamndata['noserch'].present?
        unless  palamndata['serch_field'].nil?
          strkey=palamndata['serch_field']
        else
          strkey=key
        end
        case palamndata['type']
        when 'textN','textNN','textD','textDT','textT'
          if @param.has_key?("#{key}_e")
            retwhere = mksqlwhere_info(strkey,palamndata,'bg',retwhere)
            retwhere = mksqlwhere_info(strkey,@param["#{key}_e"],'sm',retwhere)
          else
            retwhere = mksqlwhere_info(strkey,palamndata,'eq',retwhere)
          end
        when 'textA','textAA','textX','textJ','textKn','textKh','textXX','textMl','textP','textURL'
          if @param.has_key?("#{key}_cri")
            retwhere = mksqlwhere_info(strkey,palamndata,@param["#{key}_cri"]['value'],retwhere)
          else
            retwhere = mksqlwhere_info(strkey,palamndata,'eq',retwhere)
          end
        when 'select','selectP','radio'
          retwhere = mksqlwhere_info(strkey,palamndata,'eq',retwhere)
        when 'ckeck_list'
          unless !palamndata['msg'].nil?  || palamndata['value'].nil?
            tmpval_a = palamndata["value"].split("|")
            tmpwhere = []
            if palamndata["multiple_select"].nil?
              tmpval_a.each{|val|tmpwhere << " locate('|#{val}|',#{strkey})>0 " unless val.blank?}
            else
              tmpval_a.each{|val|tmpwhere << " #{strkey} = '#{val}' " unless val.blank?}
            end
            unless retwhere[0]=='' then retwhere[0] << " And " end
            retwhere[0] << "(#{tmpwhere.join("or")})"
          end
        when 'ckeck_list4list'
          if !palamndata['value'].blank?
            val = palamndata['value']
            palamndata['value'] = "|#{val}|"
            retwhere = mksqlwhere_info(strkey,palamndata,'pa',retwhere)
            palamndata['value'] = val
          end
        when 'check_one'
          if palamndata["value"].present? && palamndata["serch_field"].present?
            retwhere[0] << " and (#{palamndata["serch_field"]}) "
          end
        when 'hidden'
        else
          p "common_class.mksqlwhere::#{palamndata['type']}::key=#{key}!!!!!!"
        end
      end
    end
    return retwhere
  end
  #DBロード用(検索)SQLのWhere句の生成(個別) Generating the WHERE clause for SQL queries used for database loading (searches) (individually).
  def mksqlwhere_info(key,palamndata,criteria,retwhere)
    unless !palamndata['msg'].nil?  ||
        ((palamndata['value'].nil? || palamndata['value']=="") && palamndata['defVal'].nil?)
      if !palamndata['defVal'].nil? && (palamndata['value']=="" || palamndata['value'].nil? ) 
        palamndata['value'] = palamndata['defVal']
      end
      val = palamndata['value']
      retwhere[0] = "" if retwhere[0].nil?
      retwhere[0] << " And " unless retwhere[0].blank?
      case criteria
      when 'pa'
        retwhere[0] << "#{key} like ? "
        retwhere << "%#{val}%"
      when 'fr'
        retwhere[0] << "#{key} like ? "
        retwhere << "#{val}%"
      when 'bl'
        retwhere[0] << "#{key} like ? "
        retwhere << "%#{val}"
      when 'sm'
        retwhere[0] << "#{key} <= ? "
        case palamndata['type']
        when 'textD'
          val = Time.parse(val) + (24*60*60 - 1)
        when 'textDT'
          val = Time.parse(val)
        end
        retwhere << val
      when 'bg'
        retwhere[0] << "#{key} >= ? "
        case palamndata['type']
        when 'textD','textDT'
          val = Time.parse(val)
        end
        retwhere << val
      else
        retwhere[0] << "#{key} = ? "
        retwhere << val
      end
    end
    return retwhere
  end
  #DBロード用SQLのWhere句の生成(キー配列より作成) Generating the WHERE clause for SQL queries used for database loading (created from a key array).
  def mkconditions(keys,defconditions=[""])
    conditions = Marshal.load(Marshal.dump(defconditions))
    keys.each do |key|
      conditions[0] << " and " unless conditions[0].blank?
      conditions[0] << "#{key} = ? "
      conditions << getparamdata(key,'value')
    end
    return conditions
  end
  #ハッシュのコピー copy of hash
  def hash_cp(obj)
    return Marshal.load(Marshal.dump(obj))
  end
  #全データの取得 Get all data
  def get_all_data(key2)
    retdata=[]
    @paramkey.each do |key|
      palamndata = @param[key]
      unless palamndata[key2].nil?
        retdata << palamndata[key2]
      end
    end
    return retdata
  end
  #全エラーメッセージの取得 Get all error messages
  def get_all_emsg()
    retstr= ""
    retdata = get_all_data('msg')
    retstr = retdata.join("\n")
    return retstr
  end
  #DBからリストテーブルを取得する Retrieve a list table from the database.
  def getlist(listin)
    retlist=[]
    if listin[:table].nil? then listin[:table]=LunchVendor end
    if listin[:key].nil? then listin[:key]='id' end
    if listin[:text].nil? then listin[:text]='name' end
    if listin[:order].nil? then listin[:order]='id ASC' end
    if listin[:where].nil? then listin[:where]=" deleted_at is null " end
    if listin[:type].nil? then listin[:type]='array' end
    if listin[:type]=='hash' then retlist = Hash.new end
    datas = listin[:table].where(listin[:where]).order(listin[:order])
    unless datas.blank?
      case listin[:type]
      when 'array'
        retlist << [listin[:all],''] unless listin[:all].nil?
        datas.each do |dataline|
          retlist << [str_cut(dataline[listin[:text]],listin[:txtmax]),dataline[listin[:key]].to_s]
        end
      when 'hash'
        retlist[''] = listin[:all] unless listin[:all].nil?
        datas.each do |dataline|
          retlist[dataline[listin[:key]].to_s]=str_cut(dataline[listin[:text]],listin[:txtmax])
        end
      end
    end
    return retlist
  end
  #DBデータを格納する Store DB data
  def setdbdata(datas,list2str=false)
    if datas.blank?
      set_all_param("value",nil)
      return
    end
    @param.each{|pkey, data|
      key = data["field"].blank? ? pkey : data["field"]
      unless datas[key].nil?
        case data['type']
        when 'textD','textDJ'
          value = setftime_td(datas[key],"%Y/%m/%d")
        when 'textDT'
          value = setftime(datas[key],"%Y/%m/%d %H:%M")
        when 'textT'
          value = setftime(datas[key],"%H:%M")
        when 'select','selectP','radio'
          if list2str
            case data['list'].class.to_s
            when 'Array'
              data['list'].each do |val|
                if val[1]==datas[key].to_s
                  value = (val[0])
                  break
                end
              end
            when 'Hash'
              value = data['list'][datas[key]]
              if value.nil?
                value = datas[key].to_s
              end
            else
              value = datas[key].to_s
            end
          else
            value = datas[key].to_s
            unless data['format'].nil?
              if datas[key].is_a?(Time) || datas[key].is_a?(Date)
                value = datas[key].strftime(data['format'])
              end
            end
          end
        when 'ckeck_list'
          value = datas[key].to_s
          if list2str
            case data['list'].class.to_s
            when 'Array'
              data['list'].each{|txt,val| value.gsub!("|#{val}|","|#{txt}|")}
              # value.gsub!("|","、")
              # value.gsub!(/^、|、$/,"")
            when 'Hash'
              values = value.split(/\s*\|\s*/)
              strvalues = []
              values.each{|val| strvalues << data['list'][val] if !val.blank? && !data['list'][val].nil? }
              value = strvalues.join("、")
            end
          end
        when "file"
          value = datas[key].to_s
          data['file_exixts?']=datas["#{key}_file_exixts?"]
        else
          value = datas[key].to_s
        end
        data['value']=value
      else
        data['value']=""
      end
    }
  end

  #格納されているデータを再チェックする Recheck the stored data.
  def check_in_data()
    ret = true
    @param.each_pair do |key, palamndata|
      val = @param[key]['value']
      retck = checkdata(palamndata,val)
      unless retck[0].nil?
        @param[key]['msg']=retck[0]
        ret = false
      end
    end
    return ret
  end

  #POSTされたデータを取得しチェックを行う Retrieve the POSTed data and perform checks.
  def setpostdata(params,sessiondata=nil,rep=nil,not_ess_ck = false)
    ret = true
    unless params[@gname].nil?
      @param.each_pair do |key, palamndata|
        val = nil
        if rep.nil? then pkey = key else pkey = key.gsub(rep[0],rep[1]) end
        case palamndata['type']
        when 'select','selectP','textAria','check_one','ckeck_list4list'
          unless params[pkey].nil? then val = params[pkey].strip end
        when 'textD', 'textDT'
          unless params[@gname][pkey].nil? then val = params[@gname][pkey] end
        when 'ckeck_list'
          if params[pkey].is_a?(Array)
            val = "|#{params[pkey].join("|")}|"
          elsif params[pkey].is_a?(String)
            if params[pkey] =~ /\|.*\|/
              val = "#{params[pkey]}"
            else
              val = "|#{params[pkey]}|"
            end
          end
        when 'file'
          fobj = params[@gname][pkey]
          if fobj.is_a?(ActionDispatch::Http::UploadedFile)
            val = fobj.original_filename
            @param[key]['fobj']=fobj
          else
            val = params["#{pkey}_delck"].present? ? nil : params[@gname]["#{pkey}_pre_f_name"]
            @param[key]['fobj']=nil
          end

        else
          unless params[@gname][pkey].nil? then val = params[@gname][pkey].strip end 
        end
        unless val.blank?
          retck = checkdata(palamndata,val)
        
          unless retck[0].nil?
            @param[key]['msg']=retck[0]
            ret = false
          end

          unless retck[1].nil?
            val=retck[1]
          end
        else
          if palamndata['essFlg']==1 && palamndata['type']!="view" && !not_ess_ck
            @param[key]['msg']="#{palamndata['title']}#{"は必須入力です。"}"
            ret = false
          end
        end
        @param[key]['value']=val
      end
    end
    #検索条件などデータをセッションに追加/ロード Add/load data such as search criteria to the session.
    unless sessiondata.nil?
      unless params[@gname].nil?
        if ret
          tmpdata={}
          @param.each_pair do |key, palamndata|
            tmpdata[key] =palamndata['value']
          end
          sessiondata[@gname]=tmpdata
        end
      else
        unless sessiondata[@gname].nil?
          @param.each_pair do |key, palamndata|
            @param[key]['value']=sessiondata[@gname][key]
          end
        end
      end
    end
    return ret
  end
  #入力データのチェック Check input data
  def checkdata(palamndata,val)
    type = palamndata['type']
    retmsg = nil
    retval = nil
    unless palamndata['em'].nil?
      val = em2half(val)
      retval = val
    end
    if palamndata['essFlg']==1 and (val=='' or val.nil?)
      retmsg = "#{palamndata['title']}#{"は必須入力です。"}"
    else
      case type
      when 'textN'
        unless chk_hankaku_suji(val) 
          retmsg= "#{palamndata['title']}は半角数字で入力してください。"
        else
          unless palamndata['maxValue'].nil?
            if val.to_i > palamndata['maxValue']
              retmsg= "#{palamndata['title']}は#{palamndata['maxValue']}以下で入力してください。"
            end
          end
        end
      when 'textNN'
        unless chk_hankaku_suji_n(val) 
          retmsg= "#{palamndata['title']}は半角数字で入力してください。"
        end
      when 'textF'
        unless chk_hankaku_suji_f(val)
          retmsg= "#{palamndata['title']}は半角数字で入力してください。"
        end
      when 'textA'
        if chk_hankaku_eisuji(val) == false
          retmsg= "#{palamndata['title']}は半角英数字で入力してください。" 
        elsif palamndata["minlength"].present?
          if palamndata["minlength"] == palamndata["maxlength"] && val.length != palamndata["minlength"].to_i
            retmsg= "#{palamndata['title']}は#{palamndata["minlength"]}文字で入力してください。"
          elsif val.length < palamndata["minlength"].to_i || val.length > palamndata["maxlength"].to_i
            retmsg= "#{palamndata['title']}は#{palamndata["minlength"]}文字以上#{palamndata["maxlength"]}文字以下で入力してください。"
          end
        end
      when 'textAA'
        unless chk_hankaku_eiji(val) 
          retmsg= "#{palamndata['title']}は半角英数字で入力してください。"
        end
      when 'textX'
        unless chk_hankaku_eisuji_x(val) 
          retmsg= "#{palamndata['title']}は半角英数字と次の記号(-_@)で入力してください。"
        end
      when 'textXX','textPass'
        unless chk_hankaku_eisuji_xx(val) 
          retmsg= "#{palamndata['title']}は半角英数字と次の記号(-_@./)で入力してください。"
        end
      when 'textColor'
        unless chk_hankaku_eisuji_color(val) 
          retmsg= "#{palamndata['title']}は半角英数字と次の記号(#)で入力してください。"
        end
      when 'textP'
        unless chk_format_tel(val) 
          retmsg= "#{palamndata['title']}は半角数字とハイフン(-)で入力してください。"
        end
      when 'textTEL_Fixed'
        unless chk_format_tel_fixed(val)
          retmsg= "#{palamndata['title']}は指定の形式（99-9999-9999又は999-999-9999）で入力してください。"
        end
      when 'textTEL'
        unless chk_format_tel_strict(val)
          retmsg= "#{palamndata['title']}は指定の形式（999-999-9999等）で入力してください。"
        end
      when 'textD'
        ret = chk_format_date(val)
        if ret[0]
          retval=ret[1]
        else
          retmsg= "#{palamndata['title']}のフォーマット(yyyy/mm/dd)もしくは日付が不正です。"
        end
      # when 'textDJ'
      #   ret = chk_format_date_j(val)
      #   if ret[0]
      #     retval=ret[1]
      #   else
      #     retmsg= "#{palamndata['title']}のフォーマット(yyyy/mm/dd)もしくは日付が不正です。"
      #   end
      when 'textDT'
        ret = chk_format_datetime(val)
        if ret[0]
          retval=ret[1]
        else
          retmsg= "#{palamndata['title']}のフォーマット(yyyy/mm/dd HH:ii)もしくは日付が不正です。"
        end
      when 'textT'
        ret = chk_format_time(val)
        if ret[0]
          retval=ret[1]
        else
          retmsg= "#{palamndata['title']}のフォーマット(HH:ii)もしくは時間が不正です。"
        end
      when 'textTimeTerm'
        unless chk_format_time_term(val)
          retmsg= "#{palamndata['title']}のフォーマット(hh:mm-hh:mm)が不正です。"
        end
      when 'textMl','textMail'
        unless chk_format_mail(val) 
          retmsg= "#{palamndata['title']}がメールアドレスの形式ではありません。"
        end
      when 'textURL'
        unless chk_format_uri(val) 
          retmsg= "#{palamndata['title']}がURIの形式ではありません。"
        end
      when 'file'
        if val!='' and !val.nil? and !palamndata['ext_ck'].nil?
          ext_ck_list = palamndata['ext_ck'].upcase.split(",")         
          if ext_ck_list.find{|ext| ".#{ext}"== File.extname(val).upcase}.nil?
            retmsg= "#{palamndata['title']}は拡張子「#{palamndata['ext_ck']}」のファイルを指定してください。"
          end
        end
      when 'textJ','textKn','textKh','textAria'
        #チェック不要？ No need to check?
      when 'select','selectP','radio','ckeck_list4list'
        unless palamndata['ck_in'].nil? || val==""
          list = palamndata['list']
          case list.class.to_s
          when "Hash"
            unless list.key?(val)
              retval=list.key(val)
              if retval.nil?
                retmsg= "#{palamndata['title']}が指定された値ではありません。[#{val}]"
              end
            end
          when "Array"
            if list.select{|tmp| tmp[1]==val}.length==0
              if list.select{|tmp| tmp[0]==val}.length==0
                retmsg= "#{palamndata['title']}が指定された値ではありません。[#{val}]"
              end
            end
          end
        end
      when 'check_one','hidden','hiddenv','ckeck_list','view'
        #チェック不要 No need to check
      else
        retmsg="no check [#{type}]!!"
      end
    end
    return [retmsg,retval]
  end

  #入力チェックのJavaScriptを返す Return JavaScript for input validation.
  def get_input_js(key,inkey_name=nil,title_add="",not_ess_ck=false)
    retstr=""
    data = getparam(key)
    return retstr if data['inputFlg']==0
    return retstr if data['noCheck']==1
    inkey_name = key if inkey_name.nil?
    title = "#{title_add}#{data['title']}"
    ess_flg = (not_ess_ck ? 0 : data['essFlg'])
    case data['type']
    when 'textN'
      if !data['min'].blank? && !data['max'].blank?
        retstr << "strErrorMassage += check_NumOnlyP_MM(fobj.elements['#{@gname}[#{inkey_name}]'],#{ess_flg},'#{title}','#{data['min']}','#{data['max']}');\n"
      else
        retstr << "strErrorMassage += check_NumOnlyP(fobj.elements['#{@gname}[#{inkey_name}]'],#{ess_flg},'#{title}','#{data['minlength']}','#{data['maxlength']}');\n"
      end
    when 'textNN'
      retstr << "strErrorMassage += check_NumOnly(fobj.elements['#{@gname}[#{inkey_name}]'],#{ess_flg},'#{title}');\n"
    when 'textF'
      retstr << "strErrorMassage += check_NumOnlyF(fobj.elements['#{@gname}[#{inkey_name}]'],#{ess_flg},'#{title}');\n"
    when 'textA'
      retstr << "strErrorMassage += check_Alp2(fobj.elements['#{@gname}[#{inkey_name}]'],#{ess_flg},'#{title}','#{data['minlength']}','#{data['maxlength']}');\n"
    when 'textAA'
      retstr << "strErrorMassage += check_AA(fobj.elements['#{@gname}[#{inkey_name}]'],#{ess_flg},'#{title}');\n"
    when 'textX','textPass','textXX','textMl'
      retstr << "strErrorMassage += check_AlpP(fobj.elements['#{@gname}[#{inkey_name}]'],#{ess_flg},'#{title}');\n"
    when 'textColor'
      retstr << "strErrorMassage += check_Color(fobj.elements['#{@gname}[#{inkey_name}]'],#{ess_flg},'#{title}');\n"
    when 'textP'
      retstr << "strErrorMassage += check_Num(fobj.elements['#{@gname}[#{inkey_name}]'],#{ess_flg},'#{title}','#{data['minlength']}','#{data['maxlength']}');\n"
    when 'textTEL_Fixed'
      retstr << "strErrorMassage += check_Phon_Fixed(fobj.elements['#{@gname}[#{inkey_name}]'],#{ess_flg},'#{title}');\n"
    when 'textTEL'
      retstr << "strErrorMassage += check_Phon(fobj.elements['#{@gname}[#{inkey_name}]'],#{ess_flg},'#{title}');\n"
    when 'textD'
      retstr << "strErrorMassage += check_Day(fobj.elements['#{@gname}[#{inkey_name}]'],#{ess_flg},'#{title}');\n"
    when 'textT'
      retstr << "strErrorMassage += check_Time(fobj.elements['#{@gname}[#{inkey_name}]'],#{ess_flg},'#{title}');\n"
    when 'textDT'
      retstr << "strErrorMassage += check_DayTiem(fobj.elements['#{@gname}[#{inkey_name}]'],#{ess_flg},'#{title}');\n"
    when 'textTimeTerm'
      retstr << "strErrorMassage += check_TimeTerm(fobj.elements['#{@gname}[#{inkey_name}]'],#{ess_flg},'#{title}');\n"
    when 'textJ'
      retstr << "strErrorMassage += check_Txt(fobj.elements['#{@gname}[#{inkey_name}]'],#{ess_flg},'#{title}','#{data['minlength']}','#{data['maxlength']}');\n"
    when 'textKn'
      retstr << "strErrorMassage += check_ZKana(fobj.elements['#{@gname}[#{inkey_name}]'],#{ess_flg},'#{title}','#{data['minlength']}','#{data['maxlength']}');\n"
    when 'textKh'
      retstr << "strErrorMassage += check_Han_Kana(fobj.elements['#{@gname}[#{inkey_name}]'],#{ess_flg},'#{title}');\n"
    when 'textURL'
      retstr << "strErrorMassage += check_URL(fobj.elements['#{@gname}[#{inkey_name}]'],#{ess_flg},'#{title}');\n"
    when 'textMail'
      retstr << "strErrorMassage += check_Mail(fobj.elements['#{@gname}[#{inkey_name}]'],#{ess_flg},'#{title}','#{data['minlength']}','#{data['maxlength']}');\n"
    when 'check_one'
      retstr << "strErrorMassage += check_Checkbox(fobj.elements['#{inkey_name}'],#{ess_flg},'#{title}');\n"
    when 'radio'
      retstr << "strErrorMassage += check_Checkradio(fobj.elements['#{@gname}[#{inkey_name}]'],#{ess_flg},'#{title}');\n"
    when 'file'
      # 複数ファイル対応 Supports multiple files
      if data['multiple'].to_i==1
        retstr << "strErrorMassage += check_files(fobj.elements['#{@gname}[#{inkey_name}][]'],#{ess_flg},'#{title}','#{data['ext_ck']}');\n"
      else
        retstr << "strErrorMassage += check_file(fobj.elements['#{@gname}[#{inkey_name}]'],#{ess_flg},'#{title}','#{data['ext_ck']}');\n"
      end
    when 'select','ckeck_list4list'
      retstr << "strErrorMassage += check_Select_List(fobj.elements['#{inkey_name}'],#{ess_flg},'#{title}');\n"
    when 'selectP'
      retstr << "strErrorMassage += check_Select_List(fobj.elements['#{@gname}[#{inkey_name}]'],#{ess_flg},'#{title}');\n"
    when 'ckeck_list'
      retstr << "strErrorMassage += check_Checkbox(fobj.elements['#{inkey_name}[]'],#{ess_flg},'#{title}');\n"
    when 'textAria'
      retstr << "strErrorMassage += check_ess(fobj.elements['#{inkey_name}'],'#{title}');\n" if ess_flg == 1
    when 'hidden','hiddenv','view'
      #チェックなし No check
    else
      retstr << "strErrorMassage += '[#{inkey_name}]-[#{data['type']}] is not define\\n';\n"
    end
    return retstr.html_safe
  end
  #入力チェックのJavaScriptを返す Return JavaScript for input validation.
  def get_def_inck_js(not_ess_ck = false)
    inck_js=""
    @paramkey.each do |key|
      inck_js << get_input_js(key,nil,"",not_ess_ck)
      if getparamdata(key,'same_ck').present? && !not_ess_ck
        inck_js << "strErrorMassage += check_same(fobj.elements['#{@gname}[#{getparamdata(key,'same_ck')}]'],'#{getparamdata(getparamdata(key,'same_ck'),'title')}',fobj.elements['#{@gname}[#{key}]'],'#{getparamdata(key,'title')}');\n"
      end
    end
    return inck_js
  end
  #必須チェックのJavaScriptを返す Returns JavaScript for required checks.
  def get_ess_js(key,inkey_name=nil,title_add="",not_ess_ck=false)
    retstr=""
    data = getparam(key)
    return retstr if data['inputFlg']==0
    inkey_name = key if inkey_name.nil?
    title = "#{title_add}#{data['title']}"
    case data['type']
    when 'check_one','select','ckeck_list4list','textAria'
      retstr << "strErrorMassage += check_ess(fobj.elements['#{inkey_name}'],'#{title}');\n"
    when 'ckeck_list'
      retstr << "strErrorMassage += check_ess(fobj.elements['#{inkey_name}[]'],'#{title}');\n"
    when 'hidden','hiddenv','view'
      #チェックなし No check
    else
      retstr << "strErrorMassage += check_ess(fobj.elements['#{@gname}[#{inkey_name}]'],'#{title}');\n"
    end
    return retstr.html_safe
  end
  def save_files(b_path,b_name)
    Dir::mkdir(IMG_DIR,0755) unless File.exist?(IMG_DIR)
    dir_path="#{IMG_DIR}/#{b_path}"
    Dir::mkdir(dir_path,0755) unless File.exist?(dir_path)
    getparamkey.each{|key|
      if getparamdata(key,'type') == "file"
        filepath = "#{dir_path}/#{b_name}_#{key}.dat"
        fobj = @param[key]["fobj"]
        if fobj.is_a?(ActionDispatch::Http::UploadedFile)
          fobj.rewind #ポインタを先頭行へ Move the pointer to the first row.
          File.open(filepath,"wb"){ |f| f.write(fobj.read) }
        elsif @param[key]["value"].blank? && File.exist?(filepath)
          File.unlink(filepath)
        end
      end
    }unless getparamkey.blank?
  end
  #
  #アップロードされたファイルを所定の位置に保存する
  #引数::key String パラメータキー
  # Save the uploaded file to the specified location.
  # Argument::key String parameter key
  #::file_nm String サーバ側のファイル名
  #::delck String 削除フラグ
  def save_file(key,file_nm,delck)
    save_new = false
    
    param = @param[key]
    fobj = param['fobj']
    Dir::mkdir(IMG_DIR,0755) unless File.exist?(IMG_DIR)
    filepath="#{IMG_DIR}/#{param['img_dir']}"
    Dir::mkdir(filepath,0755) unless File.exist?(filepath)
    filepath << "/#{file_nm}"
    if param["value"].blank?
      filepath << ".*"
    else
      filepath << "#{File.extname(param["value"])}"
    end
    if fobj.is_a?(ActionDispatch::Http::UploadedFile)
      fobj.rewind #ポインタを先頭行へ #Pointer to the first line
      File.open(filepath,"wb"){ |f| f.write(fobj.read) }
      save_new = true
    elsif !delck.nil? && File.exist?(filepath)
      Dir.glob(filepath).each{|path| File.unlink(path)}
    end
    if save_new && !param['img_w'].blank? && !param['img_h'].blank?
      img_w = param['img_w']
      img_h = param['img_h']
      img_resize(filepath,img_w,img_h)
    end
  end
  #
  #画像ファイルのリサイズ
  #引数::filepath String 対象ファイルのパス
  #Resize image file
  #Argument::filepath String Path of the target file
  #::img_w Integer 画像幅
  #::max_img_h  Integer 画像高さ
  def img_resize(filepath,img_w,max_img_h)
    require 'rmagick'
    begin
      img = Magick::ImageList.new(filepath)
      img_h = (img_w.to_f*img.rows.to_f/img.columns.to_f).to_i
      if img_h > max_img_h
        img_w = (img_w.to_f*max_img_h.to_f/img_h.to_f).to_i
        img_h = max_img_h
      end
      img=img.resize(img_w, img_h)
      img.write(filepath)
    rescue
      raise ImageResizeError
    end
  end
  #
  #CSVデータの生成
  #引数::datas　ActiveRecords
  #返値::Array
  #Generating CSV data
  #Arguments::datas ActiveRecords
  #Return value::Array
  def mk_csv_data(datas,titlerow=true)
    require 'csv'
    output = []
    if titlerow
      output << CSV.generate_line(get_all_data('title'))
    end
    unless datas.blank?
      datas.each do |dataline|
        csvdata=[]
        setdbdata(dataline,true)
        @paramkey.each do |paramkey|
          item = @param[paramkey]
          val = item['value'].nil? ? "" : item['value']
          val = item["csvFixVal"] if val.blank? && !item["csvFixVal"].blank?
          val = item["csvForcedVal"] if item.has_key?("csvForcedVal")
          unless item["format"].blank?
            case item["type"]
            when 'textD','textDT','textT'
              if val.is_a?(Time) || val.is_a?(Date)
                val = val.strftime(item['format'])
              end
            else
              val = format(item["format"],val.to_i)
            end
          end
          csvdata << val
        end
        output << CSV.generate_line(csvdata)
      end
    end
    return output
  end
  #
  #CSV登録処理
  #引数::fobj　File CSVファイルオブジェクト
  #CSV registration process
  #Argument::fobj File: CSV file object
  #::table_obj ActiveRecord
  #::table_keys Array Or String 主キー
  #::uid Sting 更新ユーザID
  def uplode_csv_data(fobj,table_obj,table_keys,uid,merge_data=nil)
    require 'csv'
    ret = chk_csv_datas(fobj)
    if ret[:cd]
      fobj.rewind #ポインタを先頭行へ Move the pointer to the first row.
      ret[:counts][:T] = 0
      data = fobj.read
      reader = CSV.parse(data)
      reader.shift        #1行目を読み飛ばし Skip the first line
      ret[:counts][:T] += 1
      reader.each do |datas|
        ret[:counts][:T] += 1
        datas = mksqldata_from_csv(datas,uid)
        datas = datas.merge(merge_data) unless merge_data.nil?
        dataline = table_obj.create_data(table_keys,datas,uid,true,true)
        if dataline[:created_at] == dataline[:updated_at] #新規登録 New registration
          ret[:counts][:I] += 1
        else #更新登録 Update registration
          ret[:counts][:U] += 1
        end
      end
    end
    return ret
  end
  #
  #=== CSVの１行データからＤＢ登録データを生成する
  #引数::datas Array CSVの１行データ
  #=== Generate database registration data from a single row of data in a CSV file
  # Arguments::datas Array Single row of data in a CSV file
  #::uid String 登録ユーザＩＤ
  def mksqldata_from_csv(datas,uid)
    require 'kconv'
    datacount = 0
    @paramkey.each do |key|
      val = datas[datacount]
      val = val.kconv(Kconv::UTF8,Encoding::CP932).chomp unless val.blank?
      setparam(key,'value',val)
      datacount += 1
    end
    return mksqldata(uid)
  end
  #
  #=== 差分データを生成 Generate differential data
  def mk_diff_datas(no_check_keys,old_app_data,now_app_data,sub_title="")
    diff_datas = []
    @paramkey.each {|key|
      if no_check_keys.index(key).nil?
        unless old_app_data[key] == now_app_data[key]
          txt = "#{sub_title}#{getparamdata(key,"title")} ： "
          case getparamdata(key,"type")
          when "select","radio"
            txt << "[#{list_to_str(key,old_app_data[key])}] →　[#{list_to_str(key,now_app_data[key])}]"
          else
            txt << "[#{old_app_data[key]}] →　[#{now_app_data[key]}]"
          end
          diff_datas << txt
        end
      end
    }
    return diff_datas
  end
  #
  #=== listのコードから文字列を取得する Retrieve a string from a list code
  def list_to_str(key,cd)
    list = getparamdata(key,"list")
    return list2str(list,cd)
  end
  #
  #=== listのコードから文字列を取得する Retrieve a string from a list code
  def ckeck_list_str(key,vals)
    list = getparamdata(key,"list")
    retstr = []
    vals.split("|").each{|val|
      retstr << list2str(list,val) unless val.blank?
    }unless vals.blank?
    return retstr.join("、")
  end
  #値を返す return value
  def get_str_value(key)
    return "" unless has_key?(key)
    palamndata = getparam(key)
    type = palamndata['viewtype'].nil? ? palamndata['type'] : palamndata['viewtype']
    value = ""
    value = palamndata['value'].to_s unless palamndata['value'].nil?
    value = palamndata['defVal'].to_s if value.blank? && !palamndata['defVal'].nil?
    case type
    when 'textN','textNN','textF'
      value = money_format(value)
    when 'textD','textDT','textT'
      if palamndata['format'].present?
        if palamndata['value'].is_a?(Time) || palamndata['value'].is_a?(Date)
          value = palamndata['value'].strftime(palamndata['format'])
        end
      end
    when 'select','selectP','radio'
      value = list_to_str(key,value) unless value.blank?
    when 'ckeck_list'
      retstr = []
      tmpdata = []
      view_count = 1
      list_row_num = (palamndata["list_row_num"].blank? ? 500 : palamndata["list_row_num"])
      palamndata['list'].each do |val|
        unless value.index("|#{val[1]}|").nil?
          tmpdata << val[0]
          if view_count % list_row_num == 0 
            retstr << tmpdata.join("、")
            tmpdata = []
          end
          view_count += 1
        end
      end
      retstr << tmpdata.join("、")  unless tmpdata.blank?
      if retstr.size > 1
        value = "\r\n・"+retstr.join("\r\n・")
      else
        value = retstr.join("")
      end
    end
    return value
  end

  #--
  #=== その他データ管理 Other data management
  #++ 

  #その他データ　セッター Other data setter
  def set_other(key,val)
    @other_datas[key] = val
  end
  #その他データ　ゲッター Other data Getter
  def get_other(key)
    @other_datas[key]
  end
  
end
