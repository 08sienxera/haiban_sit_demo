#= WorkerCommon::UsersControllerを継承
class Bos::UsersController < WorkerCommon::UsersController
  # 共有レイアウト呼出し
  layout 'main_layout'
  before_action :set_my_oth_variable, :only =>[:edit,:update_password,:update_setting]
  
  private
  def auth_ck
    ck_bos
  end
  def set_my_oth_variable
    @my_setting = {}
    if @user.last_logined_at.present?
      @my_setting[:back_links] =[{:txt=>"メニューへ戻る",:path=>{:controller=>:home,:action=>:menu}}]
    else
      @my_setting[:back_links] =[{:txt=>"ログイン画面へ戻る",:path=>{:controller=>"/login",:action=>:login}}]
    end
  end

end