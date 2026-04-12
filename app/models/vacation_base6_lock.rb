class VacationBase6Lock < ApplicationRecord
  default_scope {where(:deleted_at => nil)}

  def self.get_locked_branch_cd_list(t_year,t_month)
    vacation_lock = self.where(:t_year=>t_year,:t_month=>t_month,:lock_flg=>1).pluck(:branche_cd)
    vacation_lock
  end

  def self.isLocked?(t_year,t_month,t_branch_cd)
    return self.get_locked_branch_cd_list(t_year,t_month).include?(t_branch_cd)
  end


  def self.lock(request_user_login_id,t_year,t_month,t_branch_cd)
    return nil unless permitted_user?(request_user_login_id,t_branch_cd)
    
    vacation_lock = self.find_or_initialize_by(:t_year=>t_year,:t_month=>t_month,:branche_cd=>t_branch_cd)

    vacation_lock.assign_attributes(
        :lock_flg=>1,
        :updated_at=>Time.now,
        :updated_uid=>request_user_login_id,
    )

    vacation_lock.assign_attributes(
        :created_at=>Time.now,
        :created_uid=>request_user_login_id,
    ) if vacation_lock.new_record?
    
    vacation_lock.save
    vacation_lock
  end

  def self.unlock(request_user_login_id,t_year,t_month,t_branch_cd)
    return nil unless permitted_user?(request_user_login_id,t_branch_cd)
    
    vacation_lock = self.find_by(:t_year=>t_year,:t_month=>t_month,:branche_cd=>t_branch_cd)
    return nil if vacation_lock.blank?
    vacation_lock.update(
        :lock_flg=>0,
        :updated_at=>Time.now,
        :updated_uid=>request_user_login_id,
    )
  end


  private
  def self.permitted_user?(login_id,t_branch_cd)
    user = User.find_by_login_id(login_id)
    return false if user.blank?
    case user[:auth_flg]
    when 0,1,2
      return false
    when 3
      branch_in_charge = user[:branch_cd].to_s
      return branch_in_charge==t_branch_cd      
    else
      return true
    end
    false
  end

end
