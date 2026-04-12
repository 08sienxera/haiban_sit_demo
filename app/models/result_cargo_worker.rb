class ResultCargoWorker < ApplicationRecord
  belongs_to :result_cargo
  belongs_to :user , :optional => true
  belongs_to :woker, primary_key: :login_id, foreign_key: :login_id
  extend Common::Func
  default_scope {where(:deleted_at => nil)}

  #
  #==当月指定日までの作業時間、残業時間集計
  def self.total_work_times(tdate,term)
    ret = {}
    datas = self.where(["work_date >= ? and work_date < ? ",term[:begin_date],tdate])
    datas.each{|dataline|
      ret[dataline[:login_id]] ||= {:work_time=>0,:orver_time=>0}
      ret[dataline[:login_id]][:work_time] += dataline[:work_time].to_i
      ret[dataline[:login_id]][:orver_time] += dataline[:orver_time].to_i
      
    }unless datas.blank?
    return ret
  end

  #
  #===実績登録後の休暇申請への設定
  def update_vacation
    # 休暇申請を取得
    vacation = Vacation.find_by({:user_id=>self[:user_id],:vacation_day=>self[:work_date]})
    return if vacation.blank?
    if vacation.base_no == 6
      return if vacation.sts==4 || vacation.sts==5
      vacation[:sts] = 4
      reason = ["公休出勤"]
      reason << vacation[:reason].to_s if vacation[:reason].present?
      vacation[:reason] = reason.join("、")
      vacation[:updated_uid] = self[:updated_uid]
      vacation[:updated_at] = Time.now()
      vacation.save
      return
    else
      reason = ["出勤"]
      reason << vacation[:reason].to_s if vacation[:reason].present?
      vacation[:reason] = reason.join("、")
      vacation[:updated_uid] = self[:updated_uid]
      vacation[:updated_at] = Time.now()
      vacation.save
    end
  end
end
