class Manager::WhCalendarsController < Manager::HomeController

  #=== 年度カレンダーを表示
  def index
    @my_setting = {:table=>WhCalendar,
      :def_where=>[],
      :back_links => [{:txt=>I18n.t("btn_labels.link_to",:to=>I18n.t("page_titles.menu")),
          :path=>{:controller=>:home ,:action => :menu} }],
      :multipart_flg=>false,
    }
    @title = I18n.t("activerecord.models.wh_calendar")
    @yyyy = (params[:yyyy].blank? ? Date.today.year + (Date.today.month == 1 ? -1 : 0) : params[:yyyy].to_i)
    @datas = WhSummary.load_calendar(@yyyy)
    @vendors = LunchVendor.getdatalist({:key=>:id,:text=>:name,:order=>:desp_index,:type=>'hash'})
    @inc_js = ["manager/wh_calendar"]
  end

  #=== 指定日の設定変更
  # リクエストパラメータ
  # t_date : 設定変更対象日を指定
  # t_col : 設定変更対象を指定
  # t_val : 設定値を指定
  def update
    case params[:t_col]
    when "wh_flg"
      dataline = WhCalendar.find_by_t_date(params[:t_date])
      unless dataline.blank?
        dataline[:wh_flg] = params[:t_val].to_i
        dataline[:updated_uid] = get_uval(:login_id)
        dataline.save
        WhSummary.recount_by_whc(dataline)
      end
      render :json => dataline.to_json, :status => 200
    when "lunch_vendor_id"
      dataline = WhCalendar.find_by_t_date(params[:t_date])
      unless dataline.blank?
        dataline[:lunch_vendor_id] = params[:t_val].to_i
        dataline[:updated_uid] = get_uval(:login_id)
        dataline.save
      end
      render :json => dataline.to_json, :status => 200
    when "h_setting_min"
      dataline = WhSummary.find_by(:t_year=>params[:t_date].slice(0,4).to_i,:t_month=>params[:t_date].slice(4,2).to_i)
      unless dataline.blank?
        dataline[:h_setting_min] = params[:t_val].to_i
        dataline[:updated_uid] = get_uval(:login_id)
        dataline.save
      end
      render :json => dataline.to_json, :status => 200
    end
  end

  #=== 対象年月のサマリーを作成
  def show
    case params[:id]
    when "mkCol"
      @t_year = params[:t_year].to_i
      @t_month = params[:t_month].to_i
      begin
        WhSummary.transaction do
          WhSummary.mk_calendar(@t_year,@t_month,LunchVendor.get_def_vendor,get_uval(:login_id))
        end
        @data = WhSummary.load_calendar(@t_year,@t_month)[@t_month]
        @vendors = LunchVendor.getdatalist({:key=>:id,:text=>:name,:order=>:desp_index,:type=>'hash'})
        render :action=>:mk_col,:layout=>nil
      rescue
        set_error("system_errors.update")
        render :controller =>:home,:action=>:error,:layout=>nil
      end
    else
      render :json => params.to_json, :status => 200
      return
    end
  end

  def test
    cv_date = ->(date){ date.strftime("%Y/%m/%d")}

    y = params["y"].to_i
    m = params["m"].to_i
    s_date,e_date = WhCalendar.resolve_term(y,m)
    

    p "開始：#{cv_date.call(s_date)}"
    p "終了：#{cv_date.call(e_date)}"
    return render :json=>{
      s_date: cv_date.call(s_date),
      e_date: cv_date.call(e_date),
      param: params
    }



  end

  private
end
