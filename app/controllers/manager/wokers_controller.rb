#= 配番作業員マスタ Assigned Worker Master
class Manager::WokersController < Manager::HomeController
  before_action :set_my_global_variable
  before_action :set_my_index_variable
  before_action :set_my_oth_variable,:except=>:index
  before_action :set_my_csv_variable,:only=>[:csv_in,:csv_input]

  def csv_output
    condition = {}
    search_data = session.dig("serch_data","Woker")
    search_applicable = search_data&.dig("applicable") #=> format"2024/07/08"
    if search_data.present?
      condition[:applicable] = Date.parse(search_applicable) if search_applicable.present? # true=>改定日指定 false=>all指定 true=>Specify revision date false=>Specify all
    else #検索なし #No search
      condition[:applicable] = Applicable.where(:section=>2).order(:applicable=>:desc).first&.applicable
    end
    @my_setting[:def_where] = condition
    super()
  end


  private
  def set_my_global_variable
    @my_setting = {:table=>Woker,
      :def_where=>[],
      :back_links => [{:txt=>I18n.t("btn_labels.link_to",:to=>I18n.t("page_titles.menu")),
          :path=>{:controller=>:home ,:action => :menu} }],
      :multipart_flg=>false,
      }
  end
  def set_my_index_variable
    @my_setting[:order] = {:applicable=>:desc,:branch_cd=>:asc,:desp_index=>:asc}
    @my_setting[:csv_in] = true
    @my_setting[:new_in] = true
    @my_setting[:new_copy] = false
  end
  def set_my_oth_variable
    @my_setting[:tbl_optins] = {:class=>"soloidline"}
    @my_setting[:destroy] = true
    @my_setting[:table_keys] = "id"
    @my_setting[:msg_key] = "s_name"
    @my_setting[:back_links] << {:txt=>I18n.t("btn_labels.link_to",:to=>I18n.t("page_titles.index",
          :name=>@my_setting[:table].model_name.human)),
          :path=>{:action => :index} }
  end
  def set_my_csv_variable
    @my_setting[:table_keys] = ["applicable","login_id"]
  end
end
