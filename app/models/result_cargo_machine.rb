class ResultCargoMachine < ApplicationRecord
  belongs_to :result_cargo
  belongs_to :machine
  extend Common::Func
  default_scope {where(:deleted_at => nil)}
  
  #
  #===実績登録後のメンテナンススケジュールへの設定
  def update_maintenance
    p "--ResultCargoMachine.update_maintenance"
    p self[:machine_id]
    p self[:machine_cd]
    p self[:maintenanc_type]
    m_mainte = MachineMaintenance.unscoped.find_by({:machine_id=>self[:machine_id],:maintenanc_type=>2,:s_date=>self[:work_date]})
    if m_mainte.blank?
      m_mainte = MachineMaintenance.new({
        :machine_id=>self[:machine_id],
        :maintenanc_type=>2,
        :s_date=>self[:work_date],
        :created_uid => self[:updated_uid],
      })
    end
    m_mainte[:e_date] = self[:e_date]
    m_mainte[:note] = self[:note]
    m_mainte[:updated_uid] = self[:updated_uid]
    m_mainte[:deleted_at] = nil
    m_mainte.save
  end
end
