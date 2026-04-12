class Manager::CargoRequestsController < Manager::HomeController
  layout "main_layout"
  before_action :get_set_tdate
  before_action :set_my_global_variable
  before_action :set_my_oth_variable,:except=>:index
  before_action :set_my_csv_variable,:only=>[:csv_in,:csv_input]

  # 作業依頼一覧画面
  def index
    @title="作業依頼一覧"
    condition1 = CargoRequest.where(:work_date=>@t_date[:t_date],:work_class=>1).order({:work_place=>:asc,:move_no=>:asc,:work_no=>:asc,:serial_no=>:asc})
    sql = Arel.sql("CAST(SUBSTRING(move_no2,3) AS UNSIGNED) ASC")
    condition2 = CargoRequest.where(:work_date=>@t_date[:t_date],:work_class=>2).order(sql)
    condition3 = CargoRequest.where(:work_date=>@t_date[:t_date],:work_class=>3).order({:work_place=>:asc,:move_no=>:asc,:work_no=>:asc,:serial_no=>:asc})
    @datas = condition1+condition2+condition3
  end

  def csv_output
    t_date = session["t_date"]
    condition = {}
    condition[:work_date] = Date.strptime(t_date,"%Y%m%d") if t_date.present?
    @my_setting[:def_where] = condition
    super()
  end

  private
  #
  #=== 表示対象日付取得：10時以降は翌々日(変更)→常に翌日
  def get_set_tdate
    @today= Date.today
    t_date = @today+1
    # t_date = (Time.now.hour < 10  ? @today+1 : @today+2)
    if params[:t_date].present? && params[:t_date] =~ /\d{8}/
      session[:t_date] = params[:t_date]
    elsif params[:t_date].blank? && session[:t_date].blank?
      session[:t_date] = t_date.strftime("%Y%m%d")
    end
    @t_date = WhCalendar.find_by_t_date(Date.strptime(session[:t_date], "%Y%m%d"))
  end
  def set_my_global_variable
    @my_setting = {:table=>CargoRequest,
      :def_where=>[],
      :back_links => [
        {:txt=>I18n.t("btn_labels.link_to",:to=>I18n.t("page_titles.menu")),:path=>{:controller=>:home ,:action => :menu} },
      ],
      :multipart_flg=>false,
      }
  end
  def set_my_oth_variable
    @my_setting[:tbl_optins] = {:class=>"soloidline"}
    @my_setting[:destroy] = true
    @my_setting[:table_keys] = "id"
    @my_setting[:msg_key] = "work_name"
    @my_setting[:back_links] << {:txt=>I18n.t("btn_labels.link_to",:to=>I18n.t("page_titles.index",
                                    :name=>@my_setting[:table].model_name.human)),
                                    :path=>{:action => :index} }
  end
  def set_my_csv_variable
    @my_setting[:table_keys] = ["work_date","work_class","move_no","move_no2","serial_no"]
  end
  def cc_adjustment
    @cc.setparam('work_date','defVal',@t_date[:t_date].try(:strftime,"%Y/%m/%d"))
  end
end
