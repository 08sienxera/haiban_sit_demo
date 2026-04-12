# coding: utf-8

#
#=== 抽象ActiveRecordの共通関数モジュール
# 各クラスでextendして利用する

#画面遷移エラー
class BadRequestError < StandardError; end
#バリデーションエラー
class ValidateParamsError < StandardError; end
#ログインチェックエラー
class LoginCheckError < StandardError; end
#重複登録エラー
class DuplicationError < StandardError; end
#存在無しエラー
class NotFoundError < StandardError; end
#上限チェックエラー
class LimitOverError < StandardError; end
#画像リサイズエラー
class ImageResizeError < StandardError; end

module Common::Func
  #
  #===一覧取得
  #引数:: page Integer ページNo
  #:: select String 抽出項目
  #:: where Array 抽出条件
  #:: order String 抽出順
  #:: include String 外部接続
  # 戻り値 ::　テーブルデータ　ActiveRecord
  def get_list(page,select,where,order,include=nil,limit = LIST_LIMIT)
    data = self.paginate(:page => page, :per_page => limit)
    data = data.select(select) if select.present?
    data = data.includes(include) if include.present?
    data = data.where(where) if where.present?
    #data = data.references(references) if references.present?
    data = data.order(order) if order.present?
    return data
  end

  #
  #===1行データ取得
  #引数:: conditions Array 抽出条件
  # 戻り値 ::　テーブルデータ　ActiveRecord
  def get_first(conditions)
    data = self.find_by(conditions)
    return data
  end

  #
  #=== 登録・更新
  #引数:: p_key String||Array 主キー
  #:: datas Hash 登録・更新データ
  #:: uid String 登録・更新ユーザID
  #:: mul_flg 重複可否フラグ(可：true,不可：false)
  def create_data(p_key,datas,uid,mul_flg = false,unscoped = false)
    datas[:updated_uid] = uid unless uid.nil?
    if p_key.is_a?(Array)
      conditions = [""]
      p_key.each do |key|
        conditions[0] << "And " unless conditions[0].blank?
        if datas[key].nil?
          conditions[0] << "#{key} is Null "
        else
          conditions[0] << "#{key} = ? "
          conditions << datas[key]
        end
      end
    else
      conditions = ["#{p_key} = ? ",datas[p_key]]
    end
    if unscoped
      dataline = self.unscoped.find_by(conditions)
    else
      dataline = self.find_by(conditions)
    end
    if dataline.blank?
      datas[:created_uid] = uid unless uid.nil?
      dataline = self.create!(datas)
    else
      if !mul_flg
        if dataline[:deleted_at].blank?
          raise DuplicationError.new
        else
          dataline[:deleted_at] = nil
          dataline[:deleted_uid] = nil
        end
      elsif unscoped && dataline[:deleted_at].present?
        dataline[:deleted_at] = nil
      end
      dataline[:updated_at] = Time.now  #CSV更新件数補正
      dataline.update(datas)
    end
    return dataline
  end
  #
  #=== 全削除（deleted_atにデータを入れる）
  def delete_all(uid,where)
    deldata = {:deleted_at=>Time.now(),:deleted_uid=>uid}
    self.where(where).update_all(deldata)
  end

  #
  #===リストテーブルを生成する
  #引数::listin　Hash　制御データ
  def getdatalist(listin)
    extend Common::Format
    retlist=[]
    listin[:key]=:id if listin[:key].nil?
    listin[:text]=:name if listin[:text].nil?
    listin[:order]="#{listin[:key]} ASC" if listin[:order].nil?
    listin[:type]='array' if listin[:type].nil?
    if listin[:datas].present?
      datas = listin[:datas]
    else
      datas = self.all()
      datas = datas.where(listin[:where]) if listin[:where].present?
      datas = datas.order(listin[:order]) if listin[:order].present?
    end
    case listin[:type]
      when 'array'
        retlist << [listin[:all],''] unless listin[:all].nil?
        unless datas.blank?
          datas.each do |dataline|
            retlist << [str_cut(dataline[listin[:text]].to_s,listin[:txtmax]),dataline[listin[:key]].to_s]
          end
        end
      when 'hash'
        retlist={}
        retlist[listin[:all]] = '' unless listin[:all].nil?
        unless datas.blank?
          datas.each do |dataline|
            retlist[dataline[listin[:key]].to_s]=str_cut(dataline[listin[:text]].to_s,listin[:txtmax])
          end
        end
    end
    return retlist
  end
  #
  #===リスト取得(共通名称)
  def get_my_list(type="array")
    return self.getdatalist({:key=>:id,:text=>:name,
        :order=>"desp_index asc",:type => type})
  end
  #
  #
  def list_to_str(arrays,cd)
    begin
      arrays.each do |array|
        return array[0] if array[1] == cd
      end
    rescue
    end
    return ""
  end
  #
  #===ユニークデータ抽出
  def get_uniq_data(datalist,key)
    ret = []
    datalist.each{|data|
      ret << data[key] if data[key].present?
    }unless datalist.blank?
    return ret.uniq
  end


  #
  #=== 文字列の途中カット
  # 引数 :: str String 値
  # ::vmaxlength　Int　表示文字数
  # ::bwd String 後文字
  # 戻り値 ::　String 先頭からvmaxlength文字までのの文字列
  def str_cut(str,vmaxlength = nil, bwd = "...")
    if str.class.to_s == "String"
      retstr = str
      unless vmaxlength.nil?
        if str.split(//u).length > vmaxlength
          retstr = "#{str.split(//u)[0..vmaxlength-1].join}#{bwd}"
        end
      end
    end
    return retstr
  end
  #
  #=== 時間の差分を取得
  def h_between(st,et)
    ret = 1
    if st =~ /(\d{2}):(\d{2})/ && et =~ /(\d{2}):(\d{2})/
      sa = st.split(":")
      ea = et.split(":")
      ret= (ea[0].to_f - sa[0].to_f) + (ea[1].to_f - sa[1].to_f) / 60
    end
    return ret
  end
  #
  #=== 比率を算出(%)
  def cal_rate(numer,denom,keta)
    return 0 if numer == 0 || numer.blank?
    return 100 if denom == 0 || denom.blank?
    ret = (BigDecimal("#{numer}") / BigDecimal("#{denom}")) * 10 ** (keta+2)
    return BigDecimal("#{ret.round}") / (10 ** keta)
  end
  #
  #=== 緯度経度の２点間の距離を求める
  ARTH_A = 6378.137			#地球の半径(赤道半径)
  ARTH_B = 6356.752314140	#地球の半径(極半径)
  def calc_distance(lat1,lon1,lat2,lon2)
    return 9999999 if lat1.blank? || lon1.blank? || lat2.blank? || lon2.blank?
    d_lat = ((lat1 - lat2) * Math::PI/ 180.0 )         #緯度差（ラジアン）
    d_lon = ((lon1 - lon2) * Math::PI/ 180.0 )         #経度差（ラジアン）
    y_lat = (((lat1 + lat2)/2) * Math::PI/ 180.0 )     #緯度の平均値
    e2 = (ARTH_A**2 - ARTH_B**2) / ARTH_A**2
    m_num = ARTH_A * (1 - e2)
    w  = Math.sqrt(1 - e2 * Math.sin(y_lat)**2 )
    m = m_num / w**3
    n = ARTH_A / w
    return Math.sqrt((d_lat * m)**2 + (d_lon * n * Math.cos(y_lat))**2)
  end
  #
  #=== Sjis変換用
  def for_kconv_sjis(val)
    ret = val.gsub(/([―ソЫ噂浬欺圭構蚕十申曾箪貼能表暴予禄兔喀媾彌拿杤歃濬畚秉綵臀藹觸軆鐔饅鷭])/){|w5c| "#{w5c}\\"}
    return ret.gsub(/([￥／：＊？“＜｜＞”\\\/:\*\?\"<>\|])/,"")
  end
  #
  #=== 日付の月数差分
  def date_diff_m(s_date,e_date)
    return 0 unless s_date.is_a?(Date)
    return 0 unless e_date.is_a?(Date)
    return (e_date.year - s_date.year) * 12 + e_date.month - s_date.month - (e_date.day >= s_date.day ? 0 : 1)
  end
end
