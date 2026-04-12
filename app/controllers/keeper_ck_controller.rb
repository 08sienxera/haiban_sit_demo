# coding: utf-8
#--
#***************************************************************************
#*     ｼｽﾃﾑ名    ：    
#*     ｻﾌﾞｼｽﾃﾑ名 ：    IDC 生き死にチェック連携用
#*     ﾌｧｲﾙ名    ：    keeper_ck_controller.rb
#*     作成      ：    2010/12/25 SEIKO N.Ooshige
#*     変更	：    
#***************************************************************************
#++

#= IDC 生き死にチェック連携用
class KeeperCkController < ApplicationController
  skip_before_action :verify_authenticity_token
  #=== チェックを実行
  def index
      ret = "OK"
      count = User.count(:id)
      ret = "NG" if count.blank? || count == 0
    render :xml => "<ret><mrsts>#{ret}</mrsts></ret>", :status => 200
  end
end
