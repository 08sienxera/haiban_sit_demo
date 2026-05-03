module CargoEditUser extend ActiveSupport::Concern
  #== callback、scope
  included do
  end

  #== クラスメソッド  
  module ClassMethods

    # 配番編集可否
    def can_edit(work_date,request_user_login_id)
      return false if work_date.blank? || request_user_login_id.blank?
      cargos = self.where(:work_date=>work_date)
      return true if cargos.blank?
      return true if cargos.where(:on_edit_uid=>request_user_login_id).present?
      return true if cargos.where("on_edit_at >= ?",4.hours.ago).blank?
      return false if cargos.where.not(:on_edit_uid=>nil).present?
      return false
    end

    # ロック可能ユーザ？
    def can_lock_user?(login_id)
      user = User.find_by_login_id(login_id)
      return false unless user
      return user[:auth_flg].to_i==4 || user[:auth_flg].to_i==5
    end

    # ロック中のユーザを返す
    def locked_by(work_date)
      locked_cargo = self.where("work_date = ? and on_edit_at >= ?",work_date,4.hours.ago).where.not(:on_edit_uid=>nil)
      return nil if locked_cargo.blank?
      lock_user = User.find_by_login_id(locked_cargo[0][:on_edit_uid])
      lock_user
    end



    # 他ユーザの編集を制限
    def confine(work_date,request_user_login_id)
      return false unless self.can_edit(work_date,request_user_login_id)
      req_user = User.find_by_login_id(request_user_login_id)
      return false if req_user.blank? || ([0,1,2,3].include?(req_user[:auth_flg].to_i))
      cargos = self.where(:work_date=>work_date)
      return false if cargos.blank?

      cargos.each {|cargo| cargo.update!(:on_edit_uid=>request_user_login_id,:on_edit_at=>Time.now)}
      return true

    end

    # 制限を解除
    def release(work_date,request_user_login_id)
      return false unless self.can_edit(work_date,request_user_login_id)

      self.where(:work_date=>work_date).update_all(:on_edit_uid=>nil,:on_edit_at=>nil)
      return true
    end

  end

end
