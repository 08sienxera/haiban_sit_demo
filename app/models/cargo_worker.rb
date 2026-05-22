# coding: utf-8
class CargoWorker < ApplicationRecord
  belongs_to :cargo, class_name: 'Cargo', primary_key: :id,foreign_key: :cargo_id
  belongs_to :user , :optional => true
  belongs_to :woker, primary_key: :login_id, foreign_key: :login_id
  extend Common::Func
  default_scope {where(:deleted_at => nil)}
  #
  #=== 当月指定日までの作業時間、残業時間集計 Aggregation of working hours and overtime hours up to the specified date of the current month
  def self.total_work_times(tdate,term)
    ret = {}
    #当年前月までの残業時間 Overtime hours up to the previous month of the current year
    if term[:end_date].month < 4
      where = ["aggr_flg='W' And ((t_year=? And t_month between 4 and 12) Or (t_year=? And t_month between 1 and ?)) ",term[:end_date].year - 1,term[:end_date].year,(term[:end_date].month - 1)]
    else
      where = {:t_year=>term[:end_date].year,:t_month=>[4..(term[:end_date].month - 1)],:aggr_flg=>"W"}
    end
    datas = WorkTimeAggregate.where(where)
    datas.each{|dataline|
      # ret[dataline[:t_cd]] ||= {:y_work_time=>0,:y_orver_time=>0,:work_time=>0,:orver_time=>0}
      ret[dataline[:t_cd]] ||= {:y_work_time=>0,:y_orver_time=>0,:work_time=>0,:orver_time=>0,:p_work_time=>0,:p_orver_time=>0,:work_time2=>0,:orver_time2=>0}
      ret[dataline[:t_cd]][:y_work_time] += dataline[:work_time].to_i
      ret[dataline[:t_cd]][:y_orver_time] += dataline[:orver_time].to_i
      ret[dataline[:t_cd]][:p_work_time] += dataline[:p_work_time].to_i
      ret[dataline[:t_cd]][:p_orver_time] += dataline[:p_orver_time].to_i
    }
    #当月前日までの残業時間 Overtime hours up to the previous day of the month
    datas = WorkTimeSummary.where(["aggr_flg='W' and work_date >= ? and work_date < ? ",term[:begin_date],tdate])
    datas.each{|dataline|
      # ret[dataline[:t_cd]] ||= {:y_work_time=>0,:y_orver_time=>0,:work_time=>0,:orver_time=>0}
      ret[dataline[:t_cd]] ||= {:y_work_time=>0,:y_orver_time=>0,:work_time=>0,:orver_time=>0,:p_work_time=>0,:p_orver_time=>0,:work_time2=>0,:orver_time2=>0}
      ret[dataline[:t_cd]][:work_time] += dataline[:work_time].to_i
      ret[dataline[:t_cd]][:orver_time] += dataline[:orver_time].to_i
      ret[dataline[:t_cd]][:work_time2] += dataline[:p_work_time].to_i
      ret[dataline[:t_cd]][:orver_time2] += dataline[:p_orver_time].to_i
    }unless datas.blank?
    return ret
  end

  def current_woker
    woker = Woker.find_by(login_id: self.login_id, applicable: Applicable.get_applicable(2, self.work_date))
    woker
  end
end
