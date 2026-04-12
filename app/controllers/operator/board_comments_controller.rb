
#= 現場作業者はコメント機能中止のため未使用
class Operator::BoardCommentsController < Operator::HomeController
  before_action :login_ck, :except => [:error]
  before_action :set_my_oth_variable, :except => [:create]

  
  def create
    @board = Board.find(params[:board_id])
    if @board.present?
      begin
        @board.add_comment(get_uval(:id),params[:board_comment_body])
        flash[:msg] = "コメントを書き込みました"
        redirect_to :controller=>"operator/boards",:action=>:show,:id=>params[:board_id]
      rescue => e
        set_error("system_errors.update")
        redirect_to :controller =>:home,:action=>:error
      end
    else
      set_error("system_alert.not_fund")
      redirect_to :controller =>:home,:action=>:error
    end
  end
  def update
    begin
      @comment.update_comment(params[:board_comment_body],get_uval(:login_id))
      flash[:msg] = "コメントを更新しました"
      redirect_to :controller=>"operator/boards",:action=>:show,:id=>@comment.board.id
    rescue
      set_error("system_errors.update")
      redirect_to :controller =>:home,:action=>:error
      return
    end
  end
  def destroy
    begin
      @comment.delete_comment(get_uval(:login_id))
      flash[:msg] = "コメントを削除しました"
      redirect_to :controller=>"operator/boards",:action=>:show,:id=>@comment.board.id
    rescue
      set_error("system_errors.update")
      redirect_to :controller =>:home,:action=>:error
      return
    end
  end

  private 
  def set_my_oth_variable
    @comment = nil
    begin
      @comment =  BoardComment.includes(:board).where(:user_id=>get_uval(:id)).find(params[:board_comment_id])
      raise ActiveRecord::RecordNotFound unless @comment
    rescue ActiveRecord::RecordNotFound
      set_error("system_alert.not_fund")
      redirect_to :controller =>:home,:action=>:error
      return
    end
  end


end
