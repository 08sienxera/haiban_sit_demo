class Officeworker::HomeController < ApplicationController
    layout "main_layout"
    before_action :login_ck, :except => [:error]
    before_action :ck_officeworker, :except => [:error]

    #ホームトップ画面
    def menu
        @title = "トップ"
        @info = session
        @lunch_date = LunchOrder.get_today
        @menu_list = get_menu_list(get_uval(:id))

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
    private
end
