#= 改定日マスタリクエスト処理 | Revision Date Master Request Processing
class Manager::ApplicablesController < Manager::HomeController
  before_action :set_my_global_variable
  before_action :set_my_index_variable
  before_action :set_my_oth_variable,:except=>:index
  before_action :set_my_csv_variable, :only => :csv_input

  private
  def set_my_global_variable
    @my_setting = {:table=>Applicable,
      :def_where=>[],
      :back_links => [{:txt=>I18n.t("btn_labels.link_to",:to=>I18n.t("page_titles.menu")),
          :path=>{:controller=>:home ,:action => :menu} }],
      :multipart_flg=>false,
      }
  end
  def set_my_index_variable
    @my_setting[:order] = {:section=>:asc,:applicable=>:desc}
    @my_setting[:csv_in] = true
    @my_setting[:new_in] = true
    @my_setting[:new_copy] = false
  end
  def set_my_oth_variable
    @my_setting[:tbl_optins] = {:class=>"soloidline"}
    @my_setting[:destroy] = true
    @my_setting[:table_keys] = ["section","applicable"]
    @my_setting[:msg_key] = "section"
    @my_setting[:back_links] << {:txt=>I18n.t("btn_labels.link_to",:to=>I18n.t("page_titles.index",
          :name=>@my_setting[:table].model_name.human)),
          :path=>{:action => :index} }
  end
  def set_my_csv_variable
    @my_setting[:table_keys] = ["section", "applicable"]
  end

end
