class Operator::LunchOrderController < Operator::HomeController
  before_action :set_my_oth_variable,only:[:edit,:update]
  before_action :set_order_history,only:[:edit,:history]

  # 昼食注文画面 | Lunch order screen
  def edit
    @title = "昼食注文"
    @lock = @t_date < Date.today || LunchOrderLock.ck_lock(@t_date,get_uval(:branch_cd))
  end

  # 昼食注文登録、更新処理 | Lunch order registration and update processing
  def update
    if @lock||@t_date < Date.today
      flash[:error_msgs] = "注文受付が終了しました"
      redirect_to :action=>:edit
      return
    else
      begin
        @my_order[:order_date] = @t_date
        @my_order[:user_id] = get_uval(:id)
        @my_order[:branche_cd] = get_uval(:branch_cd)
        @my_order[:lunch_location_id] = params[:lunch_location_id]
        if @my_order[:lunch_location_id] == -1
          @my_order[:lunch_menu_id] = -1
          @my_order[:order_num] = 0
        else
          @my_order[:lunch_menu_id] = params[:lunch_menu_id]
          @my_order[:order_num] = 1
        end
        @my_order[:lunch_vendor_id] = @wh[:lunch_vendor_id]
        @my_order[:created_uid] = get_uval(:login_id) if @my_order.new_record?
        @my_order[:updated_uid] = get_uval(:login_id)


        # バリデーション | validation
        msgs= [] 
        if @my_order[:lunch_location_id].blank?
          msgs << "昼食配送先を選択してください"
        end
        if @my_order[:lunch_menu_id].blank?
          msgs << (@wh.wh_flg == 1 ? "（幕ノ内/からあげ）を選択して注文してください" : "（みそ汁あり/なし）を選択して注文してください")
        end
        if msgs.present?
          set_order_history()
          flash.now[:error_msgs] = msgs
          @my_order.lunch_location_id = nil
          render :action=>:edit
          return
        end

        if @my_order.valid?
          @my_order.transaction {@my_order.save}
          flash[:error_msgs] = "注文しました。"
          redirect_to :action=>:edit
          return
        end
        msgs = @my_order.errors.full_messages

        set_order_history()
        flash.now[:error_msgs] = msgs
        @my_order.lunch_location_id = nil
        render :action=>:edit

      rescue => e
        set_error("system_errors.update")
        redirect_to :controller =>:home,:action=>:error
      end
    end
  end

  # 昼食注文履歴表示 | Lunch order history display
  def history
    @title = "昼食注文履歴"
    @param = params.to_json
  end
  
  private

  def set_my_oth_variable
    @t_date = (params[:id]||params[:t_date]).to_date
    @wh = WhCalendar.find_by_t_date(@t_date) 
    if @wh.blank?
      flash[:error_msgs] = I18n.t("system_alert.blank_wh_calendar")
      redirect_to :controller => :home,:action=>:error
      return
    end

    @my_order = LunchOrder.get_lunch_order(User.find(get_uval(:id)),@t_date,true)
    @hd_style = @wh.hd_style
    @lock = LunchOrderLock.ck_lock(@t_date,get_uval(:branch_cd))
    @location = LunchLocation.getdatalist({:text=>:s_name,:order=>:desp_index}) + [["注文しない","-1"]]
    @menu = (@wh.present? ? LunchMenu.getdatalist({:order=>:desp_index,:where=>{:lunch_vendor_id=>@wh[:lunch_vendor_id]}}) : [])
    @lunch_menu = LunchMenu.getdatalist({:text=>:name,:order=>:desp_index})

    # 注文状況 | Order status
    vacation = Vacation.find_by(:user_id=>get_uval(:id),:vacation_day=>@t_date)
    vt = vacation.present?  ? VacationType.find_by_base_no(vacation[:base_no]) : nil
    vname = vt.present? ? vt.time_sheet_name : ""
    if vacation.present? && @my_order.new_record? && @my_order[:lunch_location_id] == -1 # 当日休暇あり、かつ昼食注文なし | There is a day off and no lunch order
      @order_sts = {:value=>1, :msg=>"注文しない",:vname=>vname, :color=>'#000000', :btn=>"注文"}
    elsif @my_order.new_record? # 未注文 | Not ordered
      if @lock #締め処理後 | After tightening
        @order_sts = {:value=>2, :msg=>"注文しない", :vname=>vname, :color=>'#000000', :btn=>"注文"}
      else # 締め処理前 | Before tightening
        @order_sts = {:value=>3, :msg=>"＊未注文です＊", :vname=>vname, :color=>'#ff0000', :btn=>"注文"}
      end
    else # 注文済 | Already ordered
      if @lock #締め処理後 | After tightening
        @order_sts = {:value=>4, :msg=>"＊申請済みです＊", :vname=>vname, :color=>'#000000', :btn=>"注文"}
      else # 締め処理前 | Before tightening
        @order_sts = {:value=>5, :msg=>"＊申請済みです＊", :vname=>vname, :color=>'#000000', :btn=>"注文変更"}
      end
    end
  end

  def set_order_history()
    t_date = @t_date || (params[:id]||params[:t_date]).to_date
    @location_note = LunchLocation.getdatalist({:text=>:note,:where=>"note <> ''",:type=>"hash"})
    #履歴集計 | History aggregation

    @tarm = {
      :current=>get_month(t_date),
      :last=>get_month(t_date,-1)
    }
    @t_tarm = @tarm[:current]
    current_tarm_length = @tarm[:current][:length]
    last_tarm_length = @tarm[:last][:length]
    @order_history = {
      this: LunchOrder.get_orders(get_uval(:id), current_tarm_length[:begin_date], current_tarm_length[:end_date]).filter{|lo| lo[:lunch_location_id]!=-1},
      last: LunchOrder.get_orders(get_uval(:id), last_tarm_length[:begin_date], last_tarm_length[:end_date]).filter{|lo| lo[:lunch_location_id]!=-1}
    }

    @location ||= LunchLocation.getdatalist({:text=>:s_name,:order=>:desp_index}) + [["","0"]]
    @lunch_menu = LunchMenu.getdatalist({:text=>:name,:order=>:desp_index}) + [["","0"]]
    @wh=WhCalendar.where(:t_date=>@tarm[:last][:length][:start_date]..@tarm[:current][:length][:end_date])
    @wh = @wh.pluck(:t_date).zip(@wh.pluck(:wh_flg)).to_h
  end

  #
  #==注文ロックチェック | order lock check
  # def ck_lock
    # if params[:id].present? && params[:id] =~ /\d{8}/
    #   @t_date = Date.strptime(params[:id], "%Y%m%d")
    # else
    #   @t_date = LunchOrder.get_today
    # end
    # @my_order = LunchOrder.find_by({:order_date=>@t_date,:user_id=>get_uval(:id)}) || LunchOrder.new
    # @wh = WhCalendar.find_by_t_date(@t_date) 
    # @lock = LunchOrderLock.ck_lock(@t_date,get_uval(:branch_cd))
  # end
end
