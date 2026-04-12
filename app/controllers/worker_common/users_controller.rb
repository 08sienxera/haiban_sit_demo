class WorkerCommon::UsersController < ApplicationController
  before_action :login_ck, :except => [:error]
  before_action :auth_ck, :except => [:error]
  before_action :set_cmn_oth_variable, :only =>[:edit,:update_password,:update_setting]


  #=== 変更リクエスト処理
  #paramの:targetで呼ぶ関数を切り替え
  def edit
    case params[:target]
    when 'password'
      edit_password()
    when 'setting'
      edit_setting()
    else
      flash[:error_msgs] = "画面遷移が不正です。"
      redirect_to :controller=>:home,:action=>:menu
    end
  end

  #=== ユーザ設定変更リクエスト処理
  def edit_setting
    render 'edit_setting'
  end

  #=== ユーザ設定更新
  def update_setting
    flash[:error_msgs] = []
    bbs_max_count,question,answer = params[:user].values_at(:bbs_max_count,:remind_question,:remind_answer)
    if bbs_max_count.to_i==0 || bbs_max_count.to_i>20
      flash[:error_msgs] << "「#{I18n.t("activerecord.attributes.user.bbs_max_count")}」は 1～20 の範囲で入力してください。"
    end
    if question.blank? || answer.blank?
      flash[:error_msgs] << "パスワードリマインドの「質問」と「回答」を入力してください。"
    end
    if question.length>32 || answer.length>32
      flash[:error_msgs] << "パスワードリマインドの「質問」と「回答」は32文字以下で入力してください。"
    end
    if flash[:error_msgs].length>0
      render "edit_setting"
      return  
    end

    require_fields = [:password,:bbs_max_count,:remind_question,:remind_answer,:last_logined_at]
    safety_params = user_params(require_fields)
    @user.assign_attributes(safety_params)
    begin
      if @user.save
        first_login = session[UserSessionKey].delete(:first_login)
        if first_login
          flash[:msgs] = "再度ログインしてください"
          @user.update(:last_logined_at=>Time.now)
          redirect_to :controller=>"/login",:action=>:login
        else
          @user.update(:last_logined_at=>Time.now) if @user[:last_logined_at].blank?
          flash[:error_msgs] = "ユーザ設定を更新しました。"
          redirect_to :action=>:edit,:target=>'setting'
        end
      else
        flash[:error_msgs] = @user.errors.full_messages.join(", ")
        render "edit_setting"
      end
    rescue Exception => e
      set_error("system_errors.update")
      redirect_to :controller =>:home,:action=>:error
    end
  end

  #=== ログインパスワード変更リクエスト処理
  def edit_password
    render 'edit_password'
  end

  #=== ログインパスワード更新
  def update_password
    flash.now[:error_msgs] ||= []
    require_fields = [:password]
    
    input = params[:user]

    new_password = input.delete(:password_update)
    new_password_confirmation = input.delete(:password_update_confirmation)
    
    # 入力されたパスワードが有効かチェック
    if input[:password].present?
      flash.now[:error_msgs] << "「パスワード」が一致しません。" if !@user.match_password?(input[:password])
    else
      flash.now[:error_msgs] << "「パスワード」が未入力です。"
    end
    if new_password.present? && new_password_confirmation.present?
      flash.now[:error_msgs] << "「変更後パスワード」と「変更後パスワード(確認用)」が一致しません。" if new_password!=new_password_confirmation
      flash.now[:error_msgs] << "入力された「変更後パスワード」は無効です。" if !User.password_is_valid?(new_password)    
    else
      flash.now[:error_msgs] << "「変更後パスワード」または「変更後パスワード(確認用)」が未入力です。"
    end
    
    # リマインドパスワード補完(初回ログイン時以外はUserテーブルの登録情報で補完します)
    if flash.now[:error_msgs].length > 0
      redirect_param = user_params(require_fields)
      @user.attributes = redirect_param
      render 'edit_password'
      return
    end

    input[:password] = new_password

    permited_params = user_params(require_fields)
    @user.update(permited_params)
    flash[:msgs] = [] ;flash[:msgs] << "パスワードを更新しました"
    
    first_login = session[UserSessionKey].delete(:first_login)
    if !first_login
      redirect_to @my_setting[:back_links].first[:path]
    elsif @user.remind_question.blank?
      @user.update(:last_logined_at=>Time.now)
      session[UserSessionKey][:first_login] = true
      flash[:error_msgs] = flash[:msgs] << "パスワードリマインド用の質問・回答を設定してください"
      redirect_to :controller=>:users,:action=>:edit,:target=>'setting'
    else
      flash[:msgs] << "再度ログインしてください"
      @user.update(:last_logined_at=>Time.now)
      redirect_to :controller=>"/login",:action=>:login
    end
  end

  #=== エラー画面
  def error
  end


  
  private
  def user_params(require_fields=[])
    params.require(:user).permit(*require_fields)
  end

  def set_cmn_oth_variable
    @user = User.find(get_uval(:id))
    case params[:target]
    when 'password'
      @title = "パスワード変更"
      @visible_remind_field = @user.remind_question.blank?
      @disable_link = session[UserSessionKey][:first_login] # ホームリンクの無効化

    when 'setting'
      @title = "ユーザ設定"
    else
      return
    end
  end
  def auth_ck
    raise NotImplementedError
  end
  


end