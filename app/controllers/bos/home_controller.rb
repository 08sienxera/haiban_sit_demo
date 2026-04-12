class Bos::HomeController < ApplicationController
  layout "main_layout"
  before_action :set_t_date,:except => [:error]
  before_action :login_ck, :except => [:error]
  before_action :ck_bos, :except => [:error]

  #ホームトップ画面
  def menu
    @title = "トップ"
    @info = session    
    @menu_list = get_menu_list(get_uval(:id))
    # render :json=>@menu_list

    # 未読掲示の有無
    unread_boad = BoardTarget.includes(:board).unread(get_uval(:id)).filter{|bt| 
      if bt.board.blank?
        false
      else
        bt.board.in_view_tarm?
      end
    }
    @top_message = {text:"未読の掲示があります。",action:{:controller=>:boards,:action=>:index,:target=>:Unread}} if unread_boad.present?  
    @current_monthly = get_month(Date.today)

  end
  #エラー画面
  def error
  end

  #エラー画面
  private
  def set_t_date()
    get_set_tdate()
  end
end 