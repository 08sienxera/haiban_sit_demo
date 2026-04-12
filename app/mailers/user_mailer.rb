#= 変更により未使用
class UserMailer < ApplicationMailer
    default from: 'test_info@seiko-itsolution.jp'

    # パスワード変更通知メールを送信
    def notify_new_password_mail
      @user = params[:user]
      @password = params[:password]
      return
      mail(to: @user.email, subject: '(テスト用)新パスワードのお知らせ')
    end
end
