# coding: utf-8
#= 荷役メッセージ
class CargoMsg < ApplicationRecord
  belongs_to :user , :optional => true
  belongs_to :woker, primary_key: :login_id, foreign_key: :login_id
  extend Common::Func
  default_scope {where(:deleted_at => nil)}

  def self.get_assignment_list(t_date)
    assignment = {}
    msgs = self.where(:work_date=>t_date)
    msgs.each{|msg|
      assignment[msg[:login_id]]=msg
    }
    return assignment
  end
end
