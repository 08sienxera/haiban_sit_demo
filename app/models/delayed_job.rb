# coding: utf-8
#= JOB管理 JOB management
class DelayedJob < ApplicationRecord
  extend Common::Func
  
  #一斉メールのJob削除
  #def self.delete_broadcast_mail_job(broadcast_mail_id)
  #  self.where(:queue => "send_broadcast_mail_#{broadcast_mail_id}").destroy_all
  #end
  
end
