class WorkTimeSummary < ApplicationRecord
  extend Common::Func
  default_scope {where(:deleted_at => nil)}
  #
  #===日計データ登録 | Daily accounting data registration
  def self.create_by_batch(aggr_flg,work_date,t_cd,worker_sum)
    lin = self.unscoped.find_by({:work_date=>work_date,:aggr_flg=>aggr_flg,:t_cd=>t_cd})
    if lin.blank?
      lin = self.new({:work_date=>work_date,:aggr_flg=>aggr_flg,:t_cd=>t_cd,:created_uid=>"batch"})
    end
    [:t_id,:s_time,:e_time,:bus_flg,:work_class,:work_time,:orver_time,:p_work_time,:p_orver_time,:p_early_time,:data_root].each{|key| lin[key] = worker_sum[key]}
    lin[:base_no] = worker_sum[:base_no] if lin[:base_no]!=6
    lin[:updated_uid] = "batch"
    lin[:deleted_at] = nil
    lin.save
    return lin
  end

end
