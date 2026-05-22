class LunchOrderLock < ApplicationRecord
  extend Common::Func
  default_scope {where(:deleted_at => nil)}

  #
  #==注文ロックの確認 Confirm order lock
  def self.ck_lock(order_date,branche_cd)
    lock_flg = false
    order_locks = self.where(:order_date=>order_date)
    order_locks.each{|order_lock|
      branche_group = LunchOrder::OrderBranchGroup.find{|group_cd,_| group_cd == order_lock[:branche_cd]}
      if branche_group.present?
        lock_flg = true if order_lock.is_locked? && branche_group[1].include?(branche_cd)
      else
        lock_flg = true if order_lock.is_locked? && order_lock[:branche_cd] == branche_cd
      end
    }
    lock_flg
  end
  #
  #==全グループの注文ロックの確認 Check order lock for all groups
  def self.ck_lock_all(order_date)
    ret = {}
    data_tbl = self.where(:order_date=>order_date)
    data_tbl.each{|dataline|
      ret[dataline[:branche_cd]] = true if dataline.is_locked?
    } unless data_tbl.blank?
    return ret
  end
  #
  #==注文ロック判定 Order lock judgment
  def is_locked?
    return (self[:lock_flg] == 1)
  end
end
