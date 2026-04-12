# coding: utf-8

#--
#***************************************************************************
#*     ｼｽﾃﾑ名    ：    
#*     ｻﾌﾞｼｽﾃﾑ名 ：    一時データ等削除バッチ起動
#*     ｺﾒﾝﾄ      ：
#*     作成      ：    2017/03/15 SEIKO
#*     変更	：
#***************************************************************************
#++
#=== 一時データ等削除バッチ起動
class Batch::CleanUpController < ApplicationController
  def index
    ret = Batche::CleanUp.do
    render :json => ret.to_json, :status => 200
  end

end
