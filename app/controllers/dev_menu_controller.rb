# coding: utf-8

#--
#***************************************************************************
#*     ｼｽﾃﾑ名    ：    西鉄旅行 イベント支援システム
#*     ｻﾌﾞｼｽﾃﾑ名 ：    デモ用画面
#*     ｺﾒﾝﾄ      ：
#*     作成      ：    2013/12/12 SEIKO
#*     変更	：
#***************************************************************************
#++

class DevMenuController < ApplicationController
  layout "main_layout"
  #=== デモ用メニューを生成 Generate a demo menu
  def index
    unless Rails.env.development? || Rails.env.test?
      flash.now[:error_msgs] = "#{I18n.t("system_errors.page_link")}"
      render :template=>"/application/exception",:layout=>"main_layout",:status=>404
      return
    end
    reset_session
    @title = "デモ用Ｉｎｄｅｘ"
    @disable_link = true
  end
  #=== データ補正を実行 Perform data correction
  def create
    ret = ["操作なし"]
    # ret = []
    # #2024/08/08:cargo_workers、result_cargo_workersへのbase_no補正
    # count = 0
    # #cws = CargoWorker.where("updated_at < '2024-08-08'")
    # cws = ResultCargoWorker.where("updated_at < '2024-08-08'")
    # cws.each{|cw|
    #   base_no = 1
    #   v = Vacation.find_by(:login_id=>cw[:login_id],:vacation_day=>cw[:work_date])
    #   if v.blank?
    #     v2 = Vacation.find_by(:login_id=>cw[:login_id],:origin_date=>cw[:work_date],:base_no=>7)
    #     base_no = 6 unless v2.blank?
    #   else
    #     base_no = v[:base_no]
    #   end
    #   if base_no != 1
    #     ret << "work_date=#{cw[:work_date].strftime("%y-%m-%d")},login_id=[#{cw[:login_id]}],base_no=[#{base_no}]"
    #   end
    #   cw[:base_no] = base_no
    #   cw[:updated_at] = Time.now
    #   cw.save
    #   count += 1
    #   break if count > 400
    # }
    # ret << "count=#{count}"
    render :json => ret.to_json, :status => 200
  end
end
