#= 沿岸作業マスタ
class Manager::CargoMastersController < Manager::HomeController
  before_action :set_my_global_variable
  before_action :set_my_index_variable
  before_action :set_my_oth_variable,:except=>:index


  #=== パラメータに指定した沿岸作業データを返す
  #param[:format]によりレスポンス形式をjson、htmlで切替
  def show
    if params[:format] == "json"
      data = CargoMaster.find_by_move_no(params[:id])
      ret = {:rtarget=>"#{params[:rtarget]}"}
      if data.blank?
        ret[:sts] = 404
        ret[:move_no] = "#{params[:id]}"
      else
        ret[:sts] = 200
        [:id,:move_no,:work_name,:work_place,:aggregate_category,:cargo_class].each{|key|
          ret[key] = data[key]
        }
      end
      render :json => ret.to_json, :status => 200
    else
      rtarget = "#{params[:id]}"
      @title = I18n.t("page_titles.serch",:name=>@my_setting[:table].model_name.human)
      @cc = @my_setting[:table].set_list_form(@my_setting[:table].model_name.name)
      @ss = Common::CommonClass.new(@cc.getgname)
      @ss.set_serch_params(@cc)
      @ss.setpostdata(params,session[:serch_data])
      sql_where = @ss.mksqlwhere(@my_setting[:def_where])
      strselect = @cc.mksqlselect()
      @datas = @my_setting[:table].get_list(get_page(params,@cc),strselect,sql_where,@my_setting[:order])
      @cc.setparam('move_no','link',nil)
      @cc.setparam('move_no','linkjs',"retunSerch")
      @cc.setparam('move_no','ajast',rtarget)
      @my_setting[:back_links] = nil
      @serch_action = {:action=>:show,:id=>rtarget}
      render :layout=>"pop_up"
    end
  end
  
  private
  def set_my_global_variable
    @my_setting = {:table=>CargoMaster,
      :def_where=>[],
      :back_links => [{:txt=>I18n.t("btn_labels.link_to",:to=>I18n.t("page_titles.menu")),
          :path=>{:controller=>:home ,:action => :menu} }],
      :multipart_flg=>false,
      }
  end
  def set_my_index_variable
    @my_setting[:order] = :move_no
    @my_setting[:csv_in] = true
    @my_setting[:new_in] = true
    @my_setting[:new_copy] = false
  end
  def set_my_oth_variable
    @my_setting[:tbl_optins] = {:class=>"soloidline"}
    @my_setting[:destroy] = true
    @my_setting[:table_keys] = "move_no"
    @my_setting[:msg_key] = "name"
    @my_setting[:back_links] << {:txt=>I18n.t("btn_labels.link_to",:to=>I18n.t("page_titles.index",
          :name=>@my_setting[:table].model_name.human)),
          :path=>{:action => :index} }
  end
end
