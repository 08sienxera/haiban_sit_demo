# coding: utf-8

#--
#***************************************************************************
#*     ｼｽﾃﾑ名    ：    
#*     ｻﾌﾞｼｽﾃﾑ名 ：    稼働時間集計
#*     ｺﾒﾝﾄ      ：
#*     作成      ：    2024/08/06 SEIKO
#*     変更	：
#***************************************************************************
#++

#===稼働時間集計 Work time aggregation
class Batch::WorkTimeAggregateController < ApplicationController
  def index
    ret = Batche::WorkTimeAggregate.do(params[:symd],params[:eymd])
    render :json => ret.to_json, :status => 200
  end

end
