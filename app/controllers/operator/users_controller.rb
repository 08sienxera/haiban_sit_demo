#===WorkerCommon::UsersControllerを継承
#
class Operator::UsersController < WorkerCommon::UsersController
  # 共有レイアウト呼出し
  layout 'operator_layout'
  before_action :set_my_oth_variable, :only =>[:edit,:update_password,:update_setting]

  
  private
  #=== 権限チェック
  #現場作業員であること
  def auth_ck
    ck_operator
  end

  #operatorのみ
  def set_my_oth_variable
    @my_setting = {}
    if @user.last_logined_at.present?
      @my_setting[:back_links] =[{:txt=>"メニューへ戻る",:path=>{:controller=>:home,:action=>:menu}}]
    else
      @my_setting[:back_links] =[{:txt=>"ログイン画面へ戻る",:path=>{:controller=>"/login",:action=>:login}}]
    end
    set_header_var(@user.last_logined_at.present?)
  end
  def set_header_var(visible=true)
    @header_link_enable = visible
    @user_menu_visible = visible
  end



end