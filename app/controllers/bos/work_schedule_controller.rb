class Bos::WorkScheduleController < Bos::HomeController
  before_action :get_set_tdate
  before_action :set_my_global_variable
  
  #=== 作業予定画面
  def index
    @title = "作業予定"
    @t_date = Woker.get_today()
    @t_date = Date.strptime(params[:t_date],'%Y%m%d') if params[:t_date]

    @day_info = WhCalendar.where(:t_date=>[@t_date,(@t_date+1)]).order(:t_date=>:asc)
    @work_schedule = {
      :current_day=>Woker.get_schedule(
        WhCalendar.find_by_t_date(@t_date),
        get_uval(:login_id)
      ),
      :next_day=>Woker.get_schedule(
        WhCalendar.find_by_t_date(@t_date+1),
        get_uval(:login_id)
      )
    }
    @top_message = {text:"作業メッセージがあります。",url:url_for(:controller=>:work_schedule,:action=>:index,:t_date=>@t_date)} if @work_schedule[:current_day].present? && @work_schedule[:current_day][:message].present?
  end

  private
  def set_my_global_variable
    @user = User.find(get_uval(:id))
    @links = [{txt:"メニューへ" ,path:{:controller=>:home,:action=>:menu}}]   
  end


end