#= 掲示公開対象グループリクエスト処理クラス
class Manager::BoardGroupsController < Manager::HomeController
  before_action :set_my_global_variable
  before_action :set_my_index_variable
  before_action :set_my_oth_variable,:except=>:index

  #===掲示対象のユーザ一覧を取得
  def get_target_users
    t_id = params[:id]
    if t_id
      # TODO　掲示対象作業員の取得
      if board_group = BoardGroup.includes(:board_group_woker).find_by_id(t_id)
        board_group_targets = board_group.get_user_list
        ret = {:sts=>200, :data=>board_group_targets}
      else
        ret = {:sts=>500, :msg=>"指定(id:#{t_id})の掲示グループが見つかりませんでした。"}
      end
    else
      ret = {:sts=>500, :msg=>"IDを指定してください。"}
    end
    render :json => ret.to_json, :status => 200 
  end


  private
  def set_my_global_variable
    @my_setting = {:table=>BoardGroup,
      :def_where=>[],
      :back_links => [{:txt=>I18n.t("btn_labels.link_to",:to=>I18n.t("page_titles.menu")),
          :path=>{:controller=>:home ,:action => :menu} }],
      :multipart_flg=>false,
      }
  end
  def set_my_index_variable
    @my_setting[:order] = :desp_index
    @my_setting[:csv_in] = false
    @my_setting[:new_in] = false
    @my_setting[:new_copy] = false
  end
  def set_my_oth_variable
    @my_setting[:tbl_optins] = {:class=>"soloidline"}
    @my_setting[:destroy] = true
    @my_setting[:table_keys] = "name"
    @my_setting[:msg_key] = "name"
    @my_setting[:back_links] << {:txt=>I18n.t("btn_labels.link_to",:to=>I18n.t("page_titles.index",
          :name=>@my_setting[:table].model_name.human)),
          :path=>{:action => :index} }
  end
end
