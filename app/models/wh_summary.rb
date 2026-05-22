# coding: utf-8
class WhSummary  < ApplicationRecord
  extend Common::Func
  default_scope {where(:deleted_at => nil)}
  
  # 祝日API リクエストURL | Holiday API request URL
  HolidaysApi = "https://holidays-jp.github.io/api/v1/%s/date.json"

  #
  #===対象年月のサマリーをロード | Load summary for target year/month
  def self.load_calendar(t_year,t_month=nil)
    ret = {}
    #p "--"*20
    if t_month.nil?
      year_month = self.get_year_month(t_year)
      year_month_by_year = year_month.group_by{|y,m| y}
      params = []
      values = []
      year_month_by_year.each do |y,arr|
        params << "(t_year = ? and t_month between #{arr.map{|arr| arr[1]}.min} and #{arr.map{|arr| arr[1]}.max})"
        values << y
      end
      if params.present?
        conditions = [params.join("OR"),*values]
      end
    else
      conditions = {:t_year=>t_year,:t_month=>t_month}
    end
    datas = self.where(conditions).order(:t_year,:t_month)
      #p datas
    unless datas.blank?
      datas.each{|dataline|
        ret[dataline[:t_month]] = {
          :t_year=>dataline[:t_year],
          :t_month=>dataline[:t_month],
          :s_date=>dataline[:s_date],
          :e_date=>dataline[:e_date],
          :cs_date=>dataline[:cs_date],
          :ce_date=>dataline[:ce_date],
          :sunday_num=>dataline[:sunday_num],
          :holiday_num=>dataline[:holiday_num],
          :h_setting_min=>dataline[:h_setting_min],
          :calendars=>WhCalendar.find_by_term(dataline[:s_date],dataline[:e_date])
        }
      }
    end
    return ret
  end
  #
  #===対象年月のサマリーを作成 | Create a summary for the target year and month
  def self.mk_calendar(t_year,t_month,vendors,uid)
    # if t_month==1
    #   s_date = Date.new(t_year-1,12,16)
    # else
    #   s_date = Date.new(t_year,t_month-1,16)
    # end
    # e_date = Date.new(t_year,t_month,15)

    s_date,e_date = WhCalendar.resolve_term(t_year,t_month)


    whc = WhCalendar.find_by_term(s_date,e_date)
    if whc.blank?
      WhCalendar.mk_def(t_year,vendors,uid)
      whc = WhCalendar.find_by_term(s_date,e_date)
    end

    summary = self.unscoped.find_by(:t_year=>t_year,:t_month=>t_month)
    if summary.blank?
      summary = self.new({:t_year => t_year,:t_month => t_month,:created_at=>Time.now(),:created_uid=>uid})
    end
    summary[:s_date] = s_date
    summary[:e_date] = e_date
    summary[:cs_date] = (s_date - s_date.strftime("%w").to_i)
    summary[:ce_date] = (e_date + (6-e_date.strftime("%w").to_i))
    summary[:sunday_num] = whc[:sunday_num]
    summary[:holiday_num] = whc[:holiday_num]
    summary[:h_setting_min] = 3 + whc[:holiday_num]
    summary[:updated_uid] = uid
    summary[:deleted_at] = nil if summary[:deleted_at].present?
    summary.save!
    return summary
  end
  #
  #===再計算 | recalculation
  def self.recount_by_whc(whc)
    summary = self.find_by(["? between s_date and e_date",whc[:t_date]])
    unless summary.blank?
      calendars=WhCalendar.find_by_term(summary[:s_date],summary[:e_date])
      summary[:sunday_num] = calendars[:sunday_num]
      summary.save
    end
  end
  #
  #===ApplicationController.get_monthのreturnから取得 | Obtained from return of ApplicationController.get_month
  def self.find_by_get_month(t_tarm)
    return self.find_by(:t_year=>t_tarm[:year],:t_month=>t_tarm[:month]) || {}
  end

  def self.find_by_tdate(t_date)
    wh = WhSummary.find_by("s_date <= ? and e_date >= ?",t_date,t_date);
    wh
  end

  private 
  def self.get_year_month(year)
    sm = ClosingMonth == 12 ? 1 : ClosingMonth+1
    arr = [[year,sm]]

    11.times do |i|
      last_month = arr[-1][1]
      next_month = last_month+1
      arr << [year,next_month]
    end

    arr.map! do |y,m|
      if m>12
        y = y+1
        m = m%12
      end
      [y,m]
    end
    arr
  end

end
