class Bos::LunchOrdersController < Bos::HomeController
  before_action :get_set_tdate
  before_action :set_my_global_variable
  before_action :set_my_oth_variable,:except=>:index
  before_action :set_order_lunch_variables,:only=>[:edit,:update]
  DISPLAYBRANCHGROUP = [["10","1","2"],["20","3","4"]]

  #===昼食集計画面 Lunch tally screen
  def index
    @title = "昼食集計"
    @skip_total = true
    @today = LunchOrder.get_today
    if params[:t_date].present? && params[:t_date] =~ /\d{8}/
      t_date = Date.strptime(params[:t_date], "%Y%m%d")
    else
      t_date = @today
    end
    @def_branche_cd = get_uval(:responsible_branch_cd)
    display_branch = DISPLAYBRANCHGROUP.find{|ary| ary.include?(@def_branche_cd)}
    @order_totall = LunchOrder.calc_total(t_date,display_branch)
    @order_totall[:branches] = @order_totall[:branches].select {|ary| display_branch&.include?(ary[1])}
    @order_totall[:orders] = @order_totall[:orders].select {|key,_| display_branch&.include?(key)}
    if @order_totall[:day_info].blank?
      flash[:error_msgs] = I18n.t("system_alert.blank_wh_calendar")
      redirect_to :controller => :home,:action=>:menu
      return
    end
    @t_date = t_date.strftime("%Y%m%d")
    @inc_js= ["manager/lunch_orders"]
    render :template=>"manager/lunch_orders/index"

  end

  #===注文ロック order lock
  def create
    begin
      order_date = Date.strptime(params[:t_date], "%Y%m%d")
      LunchOrderLock.transaction do
        lock = LunchOrderLock.find_by({:order_date=>order_date,:branche_cd=>params[:branche_cd]})
        if lock.blank?
          lock = LunchOrderLock.new({:order_date=>order_date,
            :branche_cd=>params[:branche_cd],
            :created_uid=>get_uval(:login_id)
            })
        end
        lock[:lock_flg] = params[:lock_flg]
        lock[:updated_uid] = get_uval(:login_id)
        lock.save
        if lock[:branche_cd] == ""
          LunchOrderLock.where({:order_date=>order_date}).update_all({:lock_flg=>lock[:lock_flg]})
        end
      end
      case params[:lock_flg]
      when "0" ; flash[:msg] = "注文〆を解除しました。"
      when "1" ; flash[:msg] = "昼食注文の受付を〆ました。"
      end
    end
    redirect_to :action=>:index,:t_date=>params[:t_date],:branche_cd=>params[:branche_cd]
    return
  end

  #===昼食更新画面 Lunch update
  def edit
    @title = "昼食更新"
    render :template=>"manager/lunch_orders/edit"
  end

  #===昼食更新処理 Lunch update
  def update
    begin
      @order[:order_date] = @t_date
      @order[:user_id] = @user_info[:id]
      @order[:branche_cd] = Woker.get_user_branch(@user_info[:login_id],@t_date)[:branch_cd]
      @order[:lunch_location_id] = params[:lunch_location_id]
      if @order[:lunch_location_id] == -1
        @order[:lunch_menu_id] = -1
        @order[:order_num] = 0
      else
        @order[:lunch_menu_id] = params[:lunch_menu_id]
        @order[:order_num] = 1
      end
      @order[:created_uid] = get_uval(:login_id) if @order.new_record?
      @order[:updated_uid] = get_uval(:login_id)
      if @order.valid?
        @order.transaction do
          @order.save
        end
        flash[:msg] = I18n.t("system_messages.update_b")
        redirect_to :action=>:index,:t_date=>@t_date.strftime("%Y%m%d"),:branche_cd=>@order[:branche_cd]
        return
      else
        flash.now[:error_msgs] = @order.errors.full_messages
      end
      render :template=>"manager/lunch_orders/edit"
      # render :action=>:edit
    rescue => e
      puts e
      set_error("system_errors.update")
      redirect_to :controller =>:home,:action=>:error
    end
  end

  
  private
  def set_my_global_variable
    @my_setting = {:table=>LunchOrder,
      :def_where=>[],
      :back_links => [{:txt=>I18n.t("btn_labels.link_to",:to=>I18n.t("page_titles.menu")),
      :path=>{:controller=>:home ,:action => :menu} }],
      :multipart_flg=>false,  
      }
  end
  def set_my_oth_variable
    @my_setting[:back_links] << {:txt=>I18n.t("btn_labels.link_to",:to=>I18n.t("page_titles.index",
          :name=>@my_setting[:table].model_name.human)),
          :path=>{:action => :index} }
  end
  def set_order_lunch_variables
    user = User.find(params[:id])
    woker = Woker.get_latest(@t_date).find_by(:login_id=>user.login_id)
    @user_info = {id: user.id,login_id: user.login_id,name: user.name,branch_cd: woker.branch_cd}
    @order = LunchOrder.get_lunch_order(user,@t_date,true)
    @wh = WhCalendar.find_by_t_date(@t_date) 
    @hd_style = @wh.hd_style
    @lock = LunchOrderLock.ck_lock(@t_date,@user_info[:branch_cd])
    @location = LunchLocation.getdatalist({:text=>:s_name,:order=>:desp_index}) + [["不要","-1"]]
    @menu = (@wh.present? ? LunchMenu.getdatalist({:order=>:desp_index,:where=>{:lunch_vendor_id=>@wh[:lunch_vendor_id]}}) : [])

    @messages = []
    @messages << "・公休日です" if @wh[:wh_flg] == 1
    vacation = Vacation.find_by(:user_id=>@user_info[:id],:vacation_day=>@t_date)
    if vacation.present?
      vt = VacationType.find_by_base_no(vacation.base_no)

      if vt.present?
        msg = "・休暇申請があります（#{vt.time_sheet_name}"
        msg += vacation.at_work_str if vacation.base_no==6
        if vacation.works_on?
          work_time = vacation.arriv_time.to_s + "～" + vacation.leav_time.to_s
          msg += "　"
          msg += work_time
        end
        msg += "）"
        @messages << msg
      end
    end
  end
end
