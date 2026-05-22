#= 休暇種別マスタ Leave type master
class Manager::VacationTypesController < Manager::HomeController
  before_action :set_my_global_variable
  before_action :set_my_index_variable
  before_action :set_my_oth_variable,:except=>:index

  private
  def set_my_global_variable
    @my_setting = {:table=>VacationType,
      :def_where=>[],
      :back_links => [{:txt=>I18n.t("btn_labels.link_to",:to=>I18n.t("page_titles.menu")),
          :path=>{:controller=>:home ,:action => :menu} }],
      :multipart_flg=>false,
      }
  end
  def set_my_index_variable
    @my_setting[:order] = :base_no
    @my_setting[:csv_in] = true
    @my_setting[:new_in] = true
    @my_setting[:new_copy] = false
  end
  def set_my_oth_variable
    @my_setting[:tbl_optins] = {:class=>"soloidline"}
    @my_setting[:destroy] = true
    @my_setting[:table_keys] = "base_no"
    @my_setting[:msg_key] = "name"
    @my_setting[:back_links] << {:txt=>I18n.t("btn_labels.link_to",:to=>I18n.t("page_titles.index",
          :name=>@my_setting[:table].model_name.human)),
          :path=>{:action => :index} }
  end
  def set_my_csv_variable
		@my_setting[:table_keys] = ["base_no"]
	end

end
