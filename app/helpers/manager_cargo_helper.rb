module ManagerCargoHelper
  # 
  def manager_cargo_print_index_data(cc,key,desp_no)
    ret = content_tag(:div,cc.getparamdata(key,"value").html_safe,:id=>"v_#{key}_#{desp_no}",:class=>"v_box",:style=>cc.getparamdata(key,"style"))
    ret << "<div id=\"i_#{key}_#{desp_no}\" style=\"display:none\">".html_safe
    ret << mkhtmlform(cc.getgname,key,cc.getparam(key))
    if key == "move_no"
      ret << link_to(content_tag(:lavel,nil,:class=>"fa-solid fa-magnifying-glass"),"JavaScript:goSerchCargoMaster('#{desp_no}')",:style=>"display:none",:id=>"serch_btn_#{desp_no}")
    end
    ret << "</div>".html_safe
    return ret.html_safe
  end
end