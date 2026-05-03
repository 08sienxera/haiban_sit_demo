class WorkerCommon::BoardsController < ApplicationController
  before_action :login_ck
  before_action :auth_ck, :except => [:error]
  before_action :set_cmn_oth_variable,:except=>[:index,:file_output]
  
  #=== 掲示一覧リクエスト処理
  def index
    @title = "掲示一覧"
    @user = User.find(get_uval(:id))
    per_page_limit = @user.get_bbs_max_count

    boards = Board.joins(:board_category).all.select(&:in_view_tarm?)
    board_with_state = boards.map{|board|
      c_user = User.find_by_login_id(board.created_uid)
      data = [board,false,false,false,c_user]
      board_target = board.board_target&.find{|bt| bt.user_id==@user.id}
      if board_target.present?
        unread_board = board_target.confirmation_m_at.blank?
        unread_comment = board.comment_count.to_i > 0 && board_target.confirmation_s_at.blank?
        data[1] = board_target.present?
        data[2] = unread_board
        data[3] = unread_comment
      end
      data
      # data = [Board,掲示対象？,未読？,コメント未読？]
    }

    @top_message = {text:"未読の掲示があります。",url:url_for(:controller=>:boards,:action=>:index,:target=>:Unread)} if board_with_state.any?{|arr| arr[2]}

    # 検索ワードの入力があれば表示対象を「すべて」
    @search_word = params[:search]
    @boards = []
    display_target = ""
    if @search_word.present?
      display_target = 'All'
    else
      display_target = params[:target] || 'Unread'  
    end

    case display_target
    when 'All'
      @boards = board_with_state.filter{|arr| arr[1]} || []
    when 'Unread'
      @boards = board_with_state.filter{|arr| arr[2]} || []
    when 'UnreadComment'
      @boards = board_with_state.filter{|arr| arr[3]} || []
    end

    # 検索ワードの入力があれば更に絞り込み
    if @search_word.present?
      @boards.filter!{|board,_,_,_,_|
        text_line = board.board_category&.name.to_s + board.subject.to_s + board.body1.to_s + board.body2.to_s
        text_line.include?(@search_word)
      }
    end

    # @boards = Board.joins(:board_category).where(:id=>@boards.map{|ar| ar[0].id})
    @boards = Board.joins(:board_category).where(:id=>@boards.map{|ar| ar[0].id}).order(:important_flg=>:desc,:view_s_dt=>:desc)
    @c_users = User.where(:login_id=>@boards.pluck(:created_uid))
    respond_to do |f|
      f.json{render :json=>@boards.to_json}
      f.html{
        @boards = @boards.paginate(page: params[:page], per_page: per_page_limit)
        @radio_settings || @radio_settings = []
        @radio_settings << {name:'未読',value:0,checked:display_target=='Unread',target:'Unread'}
        @radio_settings << {name:'コメント未読',value:1,checked:display_target=='UnreadComment',target:'UnreadComment'}
        @radio_settings << {name:'全て',value:2,checked:display_target=='All',target:'All'}
      }
    end
  end
  
  #=== 掲示詳細リクエスト処理
  def show
    @title = "掲示詳細"
    respond_to do |format|
      format.any{}
      format.html{
        @edit_permission = (@board.created_uid == get_uval(:login_id))
        @boardInformation = []
        @boardInformation <<  {:key=>"important", :head => "重要", :text => @board.important_str, :style_class => "ess" } 
        @boardInformation <<  {:key=>"view_tarm", :head => "期間", :text => @board.view_tarm_str("%Y/%m/%d %H:%M"), :style_class => "" } 
        @boardInformation <<  {:key=>"poster", :head => "投稿", :text => poster_name_format(User.find_by(login_id:@board.created_uid).name,@board.created_at), :style_class => "" } 
        @boardInformation <<  {:key=>"category", :head => "カテゴリ", :text => @board.board_category.name, :style_class => "" } 
        @boardInformation <<  {:key=>"subject", :head => "件名", :text => @board.subject, :style_class => "" } 
        @boardInformation <<  {:key=>"body",:head => "本文",:text => [@board.body1,@board.body2],:style_class => ""}

        @board_comments = []; @board.board_comment.each do |comment|
          @board_comments << {:id=>comment.id,:comment_no=>comment.comment_no,:poster=>poster_name_format(User.find_by(login_id:comment.created_uid).name,comment.created_at),:body=>comment.comment,:is_mine=>comment.user_id==@user.id}
        end
      }
      format.json{ render :json=>[@board,@board_target,@board.board_comment].to_json,:status=>200}
    end
  end
  
  #===添付ファイル送信
  def file_output
    begin
      board = Board.find(params[:id])
      raise ActionController::ParameterMissing if params[:attr].blank?
      file_name = board[params[:attr]]
      raise Errno::ENOENT if file_name.blank?
      
      path = Rails.root.join(board.get_file_path[params[:attr].to_sym])
      send_file(path,:filename=>file_name,:status=>200) 
  

    rescue ActiveRecord::RecordNotFound
        set_error("system_alert.not_fund")
        redirect_to :controller=>:home,:action=>:error
        return
    rescue ActionController::ParameterMissing
      set_error("system_errors.validate")
      redirect_to :controller=>:home,:action=>:error
      return
    rescue Errno::ENOENT
      set_error("system_errors.file_nothng")
      redirect_to :controller=>:home,:action=>:error
      return
    rescue
      set_error("system_errors.exception")
      redirect_to :controller=>:home,:action=>:error
      return
    end
  end

  
  private
  def set_cmn_oth_variable
    @user = User.find(get_uval(:id))
    begin
      @board = Board.includes([:board_comment,:board_target]).find(params[:id])
      @board_target = @board.board_target&.find_by(:user_id=>get_uval(:id))
      raise ActiveRecord::RecordNotFound.new("掲示期間が終了しています。") unless @board.in_view_tarm?
      raise ActiveRecord::RecordNotFound.new("掲示対象者に含まれていません。") if !is_manager? && @board_target.blank?
      @board_target.confirm_s(@user.login_id) if @board_target.present?
    rescue ActiveRecord::RecordNotFound => e
      flash[:error_msgs] = e.message
      redirect_to :controller =>:home,:action=>:error
      return
    rescue => e
      flash[:error_msgs] = ["エラーが発生しました",e.message]
      redirect_to :controller =>:home,:action=>:error
      return
    end
  end
  def poster_name_format(name,time)
    return "#{name}／#{time.strftime("%Y/%m/%d %H:%M")}"
  end
  def auth_ck
    raise NotImplementedError
  end

end
