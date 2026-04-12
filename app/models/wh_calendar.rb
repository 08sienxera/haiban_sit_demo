# coding: utf-8
class WhCalendar  < ApplicationRecord
  extend Common::Func
  default_scope {where(:deleted_at => nil)}
  belongs_to :lunch_vendor
  
  # 祝日API リクエストURL
  HolidaysApi = "https://holidays-jp.github.io/api/v1/%s/date.json"
  # 平日公休日フラグ
  WhList = {0=>"平日",1=>"法定休日"}

  #
  #===指定期間中のカレンダーデータを取得
  def self.find_by_term(sd,ed)
    ret = {}
    datalist = self.where(["t_date between ? and ? ",sd,ed])
    unless datalist.blank?
      ret = {:sunday_num=>0,:holiday_num=>0}
      datalist.each{|dataline|
        ret[dataline[:t_date]]={
          :wh_flg=>dataline[:wh_flg],
          :lunch_vendor_id=>dataline[:lunch_vendor_id],
          :ph_max=>dataline[:ph_max],
          :hname=>dataline[:hname],
        }
        if dataline[:wh_flg] == 1
          ret[:sunday_num]+=1 
        elsif dataline[:ph_max] == 1
          ret[:holiday_num]+=1
        end
      }
    end
    return ret
  end
  #
  #===指定年の初期値カレンダーデータを作成
  def self.mk_def(yyyy,vendors,uid)
    ret = {}
    holidays = get_holidays(yyyy)
    t_date = Date.new(yyyy,3,16)
    ed = Date.new(yyyy,12,31)
    while t_date <= ed do
      ret[t_date] = self.mk_defdata(t_date,holidays,vendors,uid)
      t_date += 1
    end
    holidays = get_holidays(yyyy+1)
    t_date = Date.new(yyyy+1,1,1)
    ed = Date.new(yyyy+1,3,15)
    while t_date <= ed do
      ret[t_date] = self.mk_defdata(t_date,holidays,vendors,uid)
      t_date += 1
    end
    return ret
  end
  def self.mk_defdata(t_date,holidays,vendors,uid)
    def_data = self.find_by_t_date(t_date)
    if def_data.blank?
      def_data = self.new({:t_date => t_date,:wh_flg => 0,:lunch_vendor_id => vendors[0],:ph_max => 0,:hname=>"",:created_uid => uid})
    end
    if t_date.strftime("%w") == "0"
      def_data[:wh_flg] = 1
      def_data[:lunch_vendor_id] = vendors[1]
    elsif t_date.strftime("%w") == "6"
      def_data[:lunch_vendor_id] = vendors[6]
    end
    if holidays.has_key?(t_date.strftime("%Y-%m-%d"))
      def_data[:lunch_vendor_id] = vendors[2]
      def_data[:ph_max] = 1
      def_data[:hname] = holidays[t_date.strftime("%Y-%m-%d")]
    end
    case t_date.strftime("%m%d")
    when "0101","0102","0103","0501","1230","1231"
      def_data[:wh_flg] = 1
      def_data[:lunch_vendor_id] = vendors[2]
    when "0301","0814","0815"
      unless t_date.strftime("%w") == "0"
        def_data[:wh_flg] = 1
        def_data[:lunch_vendor_id] = vendors[2]
      end
    when "0302","0815","0816"
      if (t_date-1).strftime("%w") == "0"
        def_data[:wh_flg] = 1
        def_data[:lunch_vendor_id] = vendors[2]
      end
    end
    def_data[:updated_uid] = uid
    def_data.save!
    return def_data
  end
  #
  #=== HolidaysApiから指定年の祝祭日データを取得
  def self.get_holidays(yyyy)
    require 'net/http'
    begin
      uri = URI.parse(HolidaysApi.sub("%s","#{yyyy}"))
      return JSON.parse(Net::HTTP.get(uri))
    rescue
      ExceptionNotifier.notify_exception($!)
    end
    return {}
  end
  #
  #===日曜・公休日＝赤、土曜日＝青となるstyleを返す
  def hd_style
    return "col-cell0" if self[:wh_flg] == 1
    case self[:t_date].strftime("%w")
    when "0" ; return "col-cell0"
    when "6" ; return "col-cell6"
    else     ; return ""
    end
  end
  #
  #===日付文字列の生成
  def str_date_html(io_flg=1)
    if io_flg==1
      return ApplicationController.helpers.date_field_tag("",
        self[:t_date],:type=>"date",:class=>"#{['imord',self.hd_style].join(" ")}",:id=>"tdatebox")
    else
      return ApplicationController.helpers.content_tag(:span,
        self[:t_date].strftime("%Y/%m/%d(#{I18n.t("date.abbr_day_names")[self[:t_date].strftime("%w").to_i]})"),:class=>"#{['rmord',self.hd_style].join(" ")}")
    end
  end
  # def str_date_html
  #   return ApplicationController.helpers.content_tag(:span,
  #     self[:t_date].strftime("%Y/%m/%d(#{I18n.t("date.abbr_day_names")[self[:t_date].strftime("%w").to_i]})"),:class=>"#{self.hd_style}")
  # end

  #
  #===公休／平日
  def str_wh_flg
    return (self[:wh_flg] == 1 ? "公休日" : "平日")
  end

  #===対象月度の開始日、終了日を算出
  def self.resolve_term(target_year, target_month)
    base_month = target_month - MonthBoundaryRule
    base_month = 12 if base_month == 0

    start_day = ClosingDate + 1
  
    if ClosingDate == 0
      start_date = Date.new(target_year, base_month, 1)
      end_date   = start_date.end_of_month
    else
      start_date = Date.new(target_year, base_month, start_day)

      end_month =
        if base_month == 12
          1
        else
          base_month + 1
        end

      end_date = Date.new(target_year, end_month, ClosingDate)
  
      start_date = start_date.prev_year if start_date > end_date
    end
    [start_date, end_date]
  end
end
