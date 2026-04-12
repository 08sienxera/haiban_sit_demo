class LoginController < ApplicationController
  layout "operator_layout"
  before_action :set_header_link_enable
  
  # ログインフォーム
  def login
    @title = "ログイン"
    @cc = User.set_login_form()
    # セッションを削除
    session[UserSessionKey] = nil
  end

  # ログイン認証
  def login_attempt
    @title = "ログイン"
    @cc = User.set_login_form()
    begin
      # 認証失敗でエラー発生、rescueにジャンプ
      session[UserSessionKey] = User.login_check(params,@cc)
      user = User.includes(:user_auth).find(session[UserSessionKey][:id])
    not_login_flg = user.last_logined_at.nil?
      # 最終ログイン日時を更新
      user.update(:last_logined_at=>Time.now)
      if is_manager?
        name_space = 'manager'
      elsif is_bos?
        name_space = 'bos'
        # 担当グループをセッションに追加
        session[UserSessionKey][:responsible_branch_cd] = user.branch_cd
        if woker = Woker.get_user_branch(get_uval(:login_id))
          # 配番作業員データをセッションに追加
          session[UserSessionKey].merge!(woker)
        end
        # 機能利用可否設定をセッションに追加
        session[UserSessionKey][:user_auth] = user.user_auth
      elsif is_officeworker?
        name_space = 'officeworker'
        # 機能利用可否設定をセッションに追加
        session[UserSessionKey][:user_auth] = user.user_auth
      else
        name_space = 'operator'
        if woker = Woker.get_user_branch(get_uval(:login_id))
          # 配番作業員データをセッションに追加
          session[UserSessionKey].merge!(woker)
        end
      end
      # 初回ログイン判定：初回ログインtrue
      if !(is_manager?) && not_login_flg
        session[UserSessionKey][:first_login] = true
        flash[:error_msgs] = "ログイン用のパスワードを再設定してください"
        # 初回ログイン対応後、最終ログイン日時を更新のため、nil設定
        user.update(:last_logined_at=>nil)
        redirect_to :controller=>"#{name_space}/users", :action=>:edit, :target=>'password' 
        return
      end
      redirect_to :controller=>"#{name_space}/home",:action=>:menu
      return
    rescue ValidateParamsError
      set_error("system_errors.validate",nil,true)
    rescue LoginCheckError
      set_error("system_errors.login",nil,true)
    rescue
      set_error("system_errors.exception")
    end
    render :action => :login
  end

  # リマインドフォーム（ログインＩＤ入力）
  def remind
    @title = "パスワードリマインド"
    @cc = User.set_remind_form()
    @my_setting = {}
    @my_setting[:back_links] =[{:txt=>"ログイン画面へ",:path=>{:controller=>"/login",:action=>:login}}]
  end

  # リマインドフォーム（回答）
  def answer
    @title = "質問に回答"
    @param_login_id = params[:remind][:login_id]
    # 指定ＩＤのユーザを取得
    user = User.find_by(login_id: @param_login_id)
    @cc = User.set_answer_form()
    # リマインド処理中のユーザをセッションに追加
    session[:remind_user_id] = user&.login_id
    @question = User.get_remind_question(@param_login_id)
  end
  

  # 回答の答合せとパスワード初期化
  def reset_password
    # セッションにリマインド処理中のユーザ情報が無い場合、エラー
    unless remind_user_id = session[:remind_user_id]
      flash[:error_msgs] = ["認証できませんでした。","従業員Noと質問の答えをご確認ください。"]
      redirect_to :action=>:remind
      return
    end
    user = User.find_by(login_id: remind_user_id)
    session.delete(:remind_user_id)

    # リマインド回答が不一致の場合、やりおなし
    unless user.answer_remind_question(params[:answer][:remind_answer])
      flash[:error_msgs] = ["認証できませんでした。","従業員Noと質問の答えをご確認ください。"]
      redirect_to :action=>:remind
      return
    end
    # ユーザパスワードを初期化
    password =  user.reset_password
    @data ={}
    @data[:message] = "新しいパスワードを「#{password}」に変更しました。"

    render 'login/reminded'
  
  end

  # 新パスワード通知
  def reminded
    render plain: "reminded"
  end

  # ログアウト
  def logout
    session[UserSessionKey] = nil
    session_clear
    redirect_to :action => :login
  end
  
  
  private
  # ヘッダのユーザ情報　表示切替
  def set_header_link_enable
    @header_link_enable= false
  end

end

