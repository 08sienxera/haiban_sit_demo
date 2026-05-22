class WorkerCommon::BoardCommentsController < ApplicationController
  before_action :login_ck
  before_action :set_referer_url
  before_action :set_my_oth_variable, :except => [:create]

  #=== 掲示コメントの新規登録 New post comment registration
  def create
    @board = Board.find(params[:board_id])
    if @board.present?
      begin
        @board.add_comment(get_uval(:id),params[:board_comment_body])
        flash[:msg] = "コメントを書き込みました"
        redirect_to @ref_url
      rescue => e
        set_error("system_errors.update")
        redirect_to :controller=>:home,:action=>:error
      end
    else
      set_error("system_alert.not_fund")
      redirect_to :controller=>:home,:action=>:error
    end
  end

  #=== 掲示コメントの更新・削除 Update/Delete posted comments
  def update
    begin
      if params[:board_comment_body].present?
        @comment.update_comment(params[:board_comment_body],get_uval(:login_id))
        flash[:msg] = "コメントを更新しました"

        redirect_to @ref_url
      else
        @comment.delete_comment(get_uval(:login_id))
        flash[:msg] = "コメントを削除しました"
        redirect_to @ref_url
        end
    rescue
      set_error("system_errors.update")
      redirect_to :controller=>:home,:action=>:error
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

  def set_referer_url
    @ref_url = request.referer
  end


end
