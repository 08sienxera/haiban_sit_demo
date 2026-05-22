#= 変更により未使用 Unused due to changes
class UserMailer < ApplicationMailer
    default from: '08sienxera@gmail.com'

    # パスワード変更通知メールを送信 Send password change notification email
    def notify_new_password_mail
      @user = params[:user]
      @password = params[:password]
      return
      mail(to: @user.email, subject: '(テスト用)新パスワードのお知らせ')
    end
end
