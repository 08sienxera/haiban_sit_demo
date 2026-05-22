class WorkTimeCsv
  include ActiveModel::Model
  include ActiveModel::Attributes
  extend Common::Func


  # CSV項目説明メモ
    #
    # 1. 従業員名（全角日本語）
    #    - 全角/半角スペースを除いた値が海陸ポータルの従業員氏名に登録されていない場合はエラーとし取込み対象外とする。
    #
    # 2. 勤怠（全角日本語）
    #    - 次のいずれかである必要がある：
    #      「通常出勤(8-16)」「休日出勤(8-16)」「通常出勤(20-4)」「休日出勤(20-4)」「通常出勤(19-2)」「休日出勤(19-2)」
    #      および休暇種別の出勤時間表用表記
    #      （「早遅」「遅出」「公休」「振休」「年休」「特休」「夏休」「産休」「忌引」「病欠」「公傷」
    #        「組休」「結婚」「代休」「明休」「出停」「通災」「特年」「欠勤」「看護」「介護」「育休」
    #        「看Ａ」「看Ｐ」「介Ａ」「介Ｐ」「年Ａ」「年Ｐ」）
    #    - 以外の文字列の場合はエラーとし取込み対象外とする。
    #
    # 3. 出勤（半角数字最大4桁）
    #    - 時間として取り扱えない値（例: 0861等）の場合はエラーとし取込み対象外とする。
    #
    # 4. 退勤（半角数字最大4桁）
    #    - 時間として取り扱えない値（例: 0861等）の場合はエラーとし取込み対象外とする。
    #    - ２直の場合は「0400」とし、32時間表記は行わないこと。
    #
    # 5. バス（全角日本語）
    #    - 「○」または空欄以外の文字列の場合はエラーとし取込み対象外とする。
  # CSV item explanation memo 
    # 
    # 1. Employee name (full-width Japanese) 
    # - If the value excluding full-width/half-width spaces is not registered in the employee name on the sea/land portal, it will be treated as an error and will not be imported. 
    # 
    # 2. Attendance (full-width Japanese) 
    # - Must be one of the following: 
    # "Normal work (8-16)" "Holiday work (8-16)" "Normal work (20-4)" "Holiday work (20-4)" "Normal work (19-2)" "Holiday work (19-2)" 
    # and notation for attendance timetable of leave type 
    # (“early or late”, “late”, “public holiday”, “paid leave”, “annual leave”, “special leave”, “summer vacation”, “maternity leave”, “bereavement”, “sick leave”, “public injury”) 
    # ``Group leave'', ``Marriage'', ``Compensatory leave'', ``Day leave'', ``Delivery leave'', ``Disaster relief'', ``Special year'', ``Absenteeism'', ``Nursing'', ``Nursing care'', ``Childcare leave'' 
    # "Care A" "Care P" "Care A" "Care P" "Year A" "Year P") 
    # If the string is other than -, it will be treated as an error and will not be imported. 
    # 
    # 3. Attendance (up to 4 half-width numbers) 
    # - If the value cannot be handled as time (e.g. 0861, etc.), it will be treated as an error and will not be imported. 
    # 
    # 4. Closing out (up to 4 half-width numbers) 
    # - If the value cannot be handled as time (e.g. 0861, etc.), it will be treated as an error and will not be imported. 
    # - For two shifts, use "0400" and do not use 32-hour notation. 
    # 
    # 5. Bus (full-width Japanese) 
    # - If it is a character string other than "○" or blank, it will be treated as an error and will not be imported.


  # 属性 | attribute
  attribute :worker_name, :string
  attribute :work_type, :string
  attribute :s_time, :string
  attribute :e_time, :string
  attribute :bus_flg, :string
  attr_accessor :validate_msg


  def self.set_input_form(key)
    form = Common::CommonClass.new(key)
    form.setparams("worker_name",{"title"=>"従業員名","type"=>"textJ",'size'=>"20","maxlength"=>"16","inputFlg"=>1,"essFlg"=>1,"align"=>"L"})
    form.setparams("work_type",{"title"=>"勤怠","type"=>"textJ",'size'=>"32","maxlength"=>"32","inputFlg"=>1,"essFlg"=>1,"align"=>"L"})
    form.setparams("s_time",{"title"=>"出勤","type"=>"textN",'size'=>"5","maxlength"=>"4","inputFlg"=>1,"essFlg"=>1,"align"=>"L"})
    form.setparams("e_time",{"title"=>"退勤","type"=>"textN",'size'=>"5","maxlength"=>"4","inputFlg"=>1,"essFlg"=>1,"align"=>"L"})
    form.setparams("bus_flg",{"title"=>"バス","type"=>"radio",'size'=>"3","maxlength"=>"1","inputFlg"=>1,"essFlg"=>0,"align"=>"L"})
    return form
  end

  def self.set_csv_form(key)
    form = self.set_input_form(key)
    form.setparam("worker_name",'exp',"全角日本語")
    form.setparam("work_type",'exp',"「通常出勤(8-16)」「休日出勤(8-16)」「通常出勤(20-4)」「休日出勤(20-4)」「通常出勤(19-2)」「休日出勤(19-2)」<br/>および休暇種別の出勤時間表用表記")
    form.setparam("s_time",'exp',"半角数字最大4桁<br/>※時間として取り扱えない値（例: 0861等）の場合はエラーとし取込み対象外となります。")
    form.setparam("e_time",'exp',"半角数字最大4桁<br/>※時間として取り扱えない値（例: 0861等）の場合はエラーとし取込み対象外となります。<br/>※２直の場合は「0400」とし、32時間表記は行わないこと。")
    form.setparam("bus_flg",'exp',"「○」または空欄以外の文字列の場合はエラーとし取込み対象外となります。")
    return form
  end



  #== クラス関数 | class function
  def self.create_from_csv_row(row)
    work_time_csv = parse_row(row)
    work_time_csv.validate_msg ||=[]
    work_time_csv.validate
    return work_time_csv
  end

  
  
  #== オブジェクト関数 | object function
  def validate()
    msg = []
    # 出勤 | attendance at work
    if self.s_time.present?
      s_match = self.s_time.to_s.match(/^(\d{2})(\d{2})$/)
      if s_match
        _,hh,mm = s_match.to_a
        msg << "[#{self.worker_name}]の出勤[#{self.s_time}]の値が不正です" unless ((0..23).cover?(hh.to_i) && (0..59).cover?(mm.to_i))
      else
        msg << "[#{self.worker_name}]の出勤[#{self.s_time}]の値が不正です"
      end
    end

    # 退勤 | leaving work
    if self.e_time.present?
      e_match = self.e_time.to_s.match(/^(\d{2})(\d{2})$/)
      if e_match
        _,hh,mm = e_match.to_a
        msg << "[#{self.worker_name}]の退勤[#{self.e_time}]の値が不正です" unless ((0..23).cover?(hh.to_i) && (0..59).cover?(mm.to_i))
      else
        msg << "[#{self.worker_name}]の退勤[#{self.e_time}]の値が不正です"
      end
    end

    # バス | bus
    unless  ["○",""].include?(self.bus_flg)
      msg << "[#{self.worker_name}]のバス[#{self.bus_flg}]は未定義です"
    end
    self.validate_msg ||= []
    self.validate_msg.push(*msg) if msg.present?
    return self
  end

  def conv_values(t_date)
    s_time = e_time = ""; bus_flg = 0
    if self.s_time.present?
      s_hhmm = self.s_time[..1] + ":" + self.s_time[-2..]
      s_time = WorkTimeAggregate.mk_time(t_date,s_hhmm,s_hhmm)
    end
    if self.e_time.present?
      e_hhmm = self.e_time[..1] + ":" + self.e_time[-2..]
      e_time = WorkTimeAggregate.mk_time(t_date,e_hhmm,e_hhmm)
      oneday = 60*60*24
      e_time += oneday if s_time.present? && s_time > e_time
    end

    bus_flg = self.bus_flg=="○" ? 1 : 0
    ret = [s_time,e_time,bus_flg]
    ret
  end

  private
  def self.parse_row(row)
    return self.new(
      :worker_name => row[0].to_s.gsub(/[ 　]/,""),
      :work_type => row[1].to_s,
      :s_time => row[2].to_s,
      :e_time => row[3].to_s,
      :bus_flg => row[4].to_s.gsub(/[ 　]/,"")
    )
  end

end
