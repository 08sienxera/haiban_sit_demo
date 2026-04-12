# -*- coding:utf-8 -*-

#--
#***************************************************************************
#*     ｼｽﾃﾑ名    ：    　
#*     ｺﾒﾝﾄ      ：    画面表示で使用する関数郡
#*     作成      ：    2012/07/27 SEIKO
#*     変更	：
#***************************************************************************
#++
module ApplicationHelper
  #表示する
  def mkhtmlform(gname,name,palamndata,inputflg = nil)
    retstr = ""
    type = palamndata['viewtype'].present? ? palamndata['viewtype'] : palamndata['type']
    value = palamndata['value'].present? ? palamndata['value'].to_s :
      (palamndata['defVal'].present? ? palamndata['defVal'] : "")
    value = str_cut(value,palamndata['vmaxlength']) if palamndata['vmaxlength'].present?
    if palamndata['msg'].present?
      retstr << "<b class=\"err\">#{palamndata['msg']}</b><br>\n"
      altstyle="background-color:#FFDDDD;"
    else
      altstyle=""
    end
    if palamndata['readonly']
      altstyle << "background-color:#DDDDDD;"
    end
    retstr << palamndata['fwd'] if palamndata['fwd'].present?
    inputflg = palamndata['inputFlg'] if inputflg.nil?

    case type
    when 'textN','textNN','textF'
      if inputflg == 1
        altstyle << "ime-mode:disabled;text-align:right;"
        retstr << text_field(gname,name,
                              {:size => palamndata['size'],:maxlength => palamndata['maxlength'],
                                :style=>"#{altstyle}#{palamndata['style']}" ,:value=>value,
                                :class=>palamndata['class'],:tabindex=>palamndata['tabindex'],
                                :readonly=>palamndata['readonly'],:onchange=>palamndata['onchange']})
      else
        retstr << content_tag("span",money_format(value),:id=>"#{name}_view")
      end
    when 'textA','textAA','textAX','textX','textXX','textMl','textP','textURL','textColor','textImg'  #半角英数入力
      if inputflg == 1
        altstyle << "ime-mode:disabled;"
        retstr << text_field(gname,name,
                              {:size => palamndata['size'],:maxlength => palamndata['maxlength'],
                                :style=>"#{altstyle}#{palamndata['style']}" ,:value=>value,
                                :class=>palamndata['class'],:tabindex=>palamndata['tabindex'],
                                :readonly=>palamndata['readonly'],:onchange=>palamndata['onchange']})

      else
        if type == 'textURL' and !palamndata['dolink'].nil?
          retstr << link_to(h(value),value,:target=>palamndata['dolink'])
        else
          retstr << h(value)
        end
      end
    when 'textTEL','textTEL_Fixed'  #電話番号
      if inputflg == 1
        altstyle << "ime-mode:disabled;"
        retstr << text_field(gname,name,
                              {:size => palamndata['size'],:maxlength => palamndata['maxlength'],
                                :style=>"#{altstyle}#{palamndata['style']}" ,:value=>value,
                                :class=>palamndata['class'],:tabindex=>palamndata['tabindex'],
                                :readonly=>palamndata['readonly'],:onchange=>palamndata['onchange']})
      else
        retstr << link_to(h(value),"tel:#{value}")
      end
    when 'textD','textDT','textT'
      unless palamndata['format'].nil?
        if palamndata['value'].is_a?(Time) || palamndata['value'].is_a?(Date)
          value = palamndata['value'].strftime(palamndata['format'])
        end
      end
      if inputflg == 1
        altstyle << "ime-mode:disabled;"
        strjs = ""
        case type
        when "textD" ; strjs = 'set_date(this);'
        when "textT" ; strjs = 'set_time(this);'
        when "textDT"
          if palamndata["defTime"].present?
            strjs = "set_datetiem(this,'#{palamndata["defTime"]}');"
          else
            strjs = "set_datetiem(this);"
          end
        end
        if palamndata['onchange'].present?
          palamndata['onchange'] = "#{strjs}#{palamndata['onchange']}"
        else
          palamndata['onchange'] = strjs
        end
        retstr << text_field(gname,name,
                              {:size => palamndata['size'],:maxlength => palamndata['maxlength'],
                                :style=>"#{altstyle}#{palamndata['style']}" ,:value=>value,
                                :class=>palamndata['class'],:tabindex=>palamndata['tabindex'],
                                :readonly=>palamndata['readonly'],:onchange=>palamndata['onchange']})
        unless palamndata['cal'].nil?
          retstr << "\n"
          retstr << link_to(image_tag('icon_cal.gif',:alt=>'カレンダー表示',:border=>0),"JavaScript:view_cal('#{name}')")
        end
      else
        retstr << h(value)
      end
    when 'textTimeTerm' #時間期間
      if inputflg == 1
        altstyle << "ime-mode:disabled;"
        strjs = ""
        strjs = 'set_timeTerm(this);'
        if palamndata['onchange'].present?
          palamndata['onchange'] << strjs
        else
          palamndata['onchange'] = strjs
        end
        retstr << text_field(gname,name,
                              {:size => palamndata['size'],:maxlength => palamndata['maxlength'],
                                :style=>"#{altstyle}#{palamndata['style']}" ,:value=>value,
                                :class=>palamndata['class'],:tabindex=>palamndata['tabindex'],
                                :readonly=>palamndata['readonly'],:onchange=>palamndata['onchange']})
      else
        retstr << h(value)
      end
    when 'textDJ'
      if inputflg == 1
        altstyle << "ime-mode:auto;"
        retstr << text_field(gname,name,
                            {:size => palamndata['size'],:maxlength => palamndata['maxlength'],
                              :style=>"#{altstyle}#{palamndata['style']}" ,:value=>value,
                              :class=>palamndata['class'],:tabindex=>palamndata['tabindex'],
                              :readonly=>palamndata['readonly'],:onchange=>palamndata['onchange']})
        unless palamndata['cal'].nil?
          retstr << "\n"
          retstr << link_to(image_tag('icon_cal.gif',:alt=>'カレンダー表示',:border=>0),"JavaScript:view_cal('#{name}')")
        end
      else
        retstr << h(value)
      end
    when 'textPass'  #パスワード
      if inputflg == 1
        retstr << password_field(gname,name, :size => palamndata['size'],:maxlength => palamndata['maxlength'],
                                :style=>"#{altstyle}#{palamndata['style']}",
                                :class=>palamndata['class'],:tabindex=>palamndata['tabindex'],
                                :readonly=>palamndata['readonly'],:onchange=>palamndata['onchange'])
      else
        retstr << "****"
      end
    when 'textMail' #メール
      if inputflg == 1
        altstyle << "ime-mode:disabled;"
        altstyle << "width:#{palamndata['width']};" unless palamndata['width'].blank?
        retstr << email_field(gname,name,
                              {:size => palamndata['size'],:maxlength => palamndata['maxlength'],
                                :style=>"#{altstyle}#{palamndata['style']}" ,:value=>value,
                                :class=>palamndata['class'],:tabindex=>palamndata['tabindex'],
                                :onpaste=>(palamndata['nopaste'] == "on" ? "return false":nil),
                                :readonly=>palamndata['readonly'],:onchange=>palamndata['onchange']})
      else
        retstr << mail_to(value)
      end
    when 'textJ','textKn',"textKh"
      if inputflg == 1
        strjs = ""
        if type=='textKn'
          strjs = 'set_Kn(this);'
        elsif type=='textKh'
          strjs = 'set_HKn(this);'
        end
        if palamndata['onchange'].present?
          palamndata['onchange'] << strjs
        else
          palamndata['onchange'] = strjs
        end
        altstyle << "ime-mode:active;"
        retstr << text_field(gname,name,
                            {:size => palamndata['size'],:maxlength => palamndata['maxlength'],
                              :style=>"#{altstyle}#{palamndata['style']}" ,:value=>value,
                              :placeholder => palamndata['placeholder'],
                              :class=>palamndata['class'],:tabindex=>palamndata['tabindex'],
                              :readonly=>palamndata['readonly'],:onchange=>palamndata['onchange']})
      else
        if palamndata['viewMax'].blank?
          retstr << h(value)
        else
          retstr << str_cut(h(value),palamndata['viewMax'])
        end
      end
    when 'textAria'
      if inputflg == 1
        altstyle << "ime-mode:active;"
        retstr << text_area_tag(name,value,
                              {:cols => palamndata['cols'],:rows => palamndata['rows'],
                                :style=>"#{altstyle}#{palamndata['style']};",
                                :class=>palamndata['class'],:tabindex=>palamndata['tabindex'],
                                :readonly=>palamndata['readonly'],:onchange=>palamndata['onchange']})
      else
        unless palamndata['setbr'].nil?
          index = 0
          value = h(value)
          tmp = value.split(//)
          while index < tmp.length do
            retstr << "#{tmp.slice(index,palamndata['setbr']).join()}<br />"
            index += palamndata['setbr']
          end
        #  while index < value.length do
        #    retstr << "#{value.slice(index,palamndata['setbr'])}<br />"
        #    index += palamndata['setbr']
        #  end
        else
          if palamndata['vclass'].present?
            retstr << "<div class=\"#{palamndata['vclass']}\">#{h(value).gsub(/\r\n|\r|\n/, "<br />")}</div>"
          else
            retstr << "#{h(value).gsub(/\r\n|\r|\n/, "<br />")}"
          end
        end
      end
    when 'select','selectP'
      inputflg = 0 if palamndata['readonly']
      unless palamndata['format'].nil?
        if palamndata['value'].is_a?(Time) || palamndata['value'].is_a?(Date)
          value = palamndata['value'].strftime(palamndata['format'])
        end
      end
      unless palamndata['list'].nil?
        if inputflg == 1
          strstyle=''
          unless palamndata['stylew'].nil?
            strstyle << "width:#{(palamndata['width']+palamndata['stylew'])}px;"
          end
          options = options_for_select(palamndata['list'],value)
          options = options.gsub("&lt;","<")
          options = options.gsub("&gt;",">")
          options = options.html_safe
          retstr << select_tag(name, options,
            :onchange=>palamndata['onchange'],:size=>palamndata['listsize'],
            :multiple=>palamndata['multiple'],:style=>"#{strstyle}#{palamndata['style']}",
            :tabindex=>palamndata['tabindex'])
        else
            case palamndata['list'].class.to_s
            when 'Array'
              palamndata['list'].each do |val|
                if val[1] == value && value !="" && val[0]!=":all"
                  retstr << (val[0])
                  break
                end
              end
            when 'Hash'
              retstr << palamndata['list'].has_key?(value) ? palamndata['list'][value] : value
            else
              retstr << value
            end
            retstr << hidden_field_tag(name, value) if palamndata['readonly']
        end
      end
    when 'radio'
      unless palamndata['list'].nil?
        view_count = 1
        list_row_num = 4
        unless palamndata['list_row_num'].nil? then list_row_num = palamndata['list_row_num'] end
        if inputflg == 1
          palamndata['list'].each do |val|
            rhtml = ""
            if val[1]==value
              rhtml = radio_button(gname,name, val[1],:onclick=>palamndata['onclick'], :checked=>'checked',
                :readonly=>palamndata['readonly'],:tabindex=>palamndata['tabindex'] )
            else
              rhtml = radio_button(gname,name, val[1],:onclick=>palamndata['onclick'],
                :disabled=>palamndata['readonly'],:tabindex=>palamndata['tabindex'])
            end
            retstr << "<label>#{rhtml}#{val[0]}</label>\n";
            retstr << (view_count % list_row_num == 0 ? "<br />" : "&nbsp;&nbsp;")
            view_count += 1
          end
        else
          palamndata['list'].each do |val|
            if val[1] == value
              retstr << (val[0])
              break
            end
          end
        end
      end
    when 'check_one'
      inputflg = 0 if palamndata['readonly']
      unless value=="not_view"
        ckeced_val = palamndata['ckeced_val'].blank? ? "1" : palamndata['ckeced_val']
        retstr << "<label>"
        if inputflg == 1
          retstr << check_box_tag(name, ckeced_val, (value == ckeced_val) ,
            :onclick=>palamndata['onclick'],:tabindex=>palamndata['tabindex'])
        else
          retstr << ((value == ckeced_val) ? '■' : '□')
        end
        retstr << "#{palamndata['label']}</label>"
      end
      retstr << hidden_field_tag(name, value) if palamndata['readonly']
    when 'ckeck_list'
      inputflg = 0 if palamndata['readonly']
      unless palamndata['list'].nil?
        view_count = 1
        list_row_num = 4
        unless palamndata['list_row_num'].nil? then list_row_num = palamndata['list_row_num'] end
        if inputflg == 1
          palamndata['list'].each do |val|
            chtml = ""
            if value.index("|#{val[1]}|").nil?
              chtml = check_box_tag("#{name}[]", val[1], false,:onclick=>palamndata['onclick'],
                      :tabindex=>palamndata['tabindex'])
            else
              chtml = check_box_tag("#{name}[]", val[1], true ,:onclick=>palamndata['onclick'],
                      :tabindex=>palamndata['tabindex'])
            end
            retstr << "<label>#{chtml}#{val[0]}</label>"
            retstr << (view_count % list_row_num == 0 ? "<br />" : "&nbsp;&nbsp;")
            view_count += 1
          end
        else
          unless palamndata['view_only'].nil?
            tmp_str_a = []
            palamndata['list'].each do |val|
              unless value.index("|#{val[1]}|").nil?
                tmp_str_a << "#{val[0]}"
                view_count += 1
              end
            end
            retstr << tmp_str_a.join("、")
          else
            palamndata['list'].each do |val|
              retstr << ( value.index("|#{val[1]}|").nil? ? '□' : '■' )
              retstr << val[0]
              retstr << (view_count % list_row_num == 0 ? "<br />" : "&nbsp;&nbsp;")
              view_count += 1
            end
          end
        end
      end
      retstr << hidden_field_tag(name, value) if palamndata['readonly']
    when 'ckeck_list4list'
      unless palamndata['list'].nil?
        view_count=0
        palamndata['list'].each do |val|
          unless value.index("|#{val[1]}|").nil?
            if view_count==0
              retstr << val[0]
              view_count+=1
            else
              retstr << " など#{value.split(/\s*\|\s*/).size - 1}件"
              break
            end
          end
        end
      end
    when 'file'
      if inputflg == 1
        unless value==""
          case(palamndata['viewform'])
          when 'img'
            filepath = "/#{IMG_URL}/#{palamndata['img_dir']}/#{name}_#{@cc::getparamdata(palamndata['img_key'],'value')}.#{palamndata['ext_ck']}"
            retstr << "#{h(value)}<br />"
            retstr << check_box_tag("#{name}_delck", "1", false)
            retstr << "画像を削除する場合はチェックしてください。<br />\n"
            #retstr << "<div id=\"img_box\">#{image_tag(filepath)}</div>"
          when 'img2'
            filepath = palamndata['url']
            retstr << "<label>"
            retstr << check_box_tag("#{name}_delck", "1", false)
            retstr << "画像を削除</label><br />\n"
            retstr << image_tag(filepath,{
                :height => "#{palamndata['img_h']}px",
                :width => "#{palamndata['img_w']}px",
                :alt => value, :title => value,})
            retstr << "<br />\n"
          when 'file'
            retstr << check_box_tag("#{name}_delck", "1", false)
            retstr << "ファイルを削除する場合はチェックしてください。<br />\n"
            if palamndata['dl_action'].present?
              file_locale = "ja"
              retstr << "#{link_to(h(value),{:action=>palamndata['dl_action'],:id=>@cc::getparamdata(palamndata['img_key'],'value'),:file_locale=>"#{file_locale}"},{:target=>"_blank"})}<br />"
            elsif palamndata['dl_path'].present? && palamndata['file_exixts?'] === true
              retstr << "#{link_to(h(value),palamndata['dl_path'].merge({:id=>name}))}<br />"
            else
              retstr << "#{value}<br />"
            end
          end
        end
        retstr << "<div class=\"box fup_box\" id=\"fup_box_#{gname}_#{name}\">ファイルをドラッグ＆ドロップもしくは<br />"
        if palamndata['multiple'].to_i==1
          retstr << file_field(gname,name, {:size => palamndata['size'],:class=>palamndata['class'],
              :onchange=>palamndata['onchange'],:tabindex=>palamndata['tabindex'],:multiple=>""})
        else
          retstr << file_field(gname,name, {:size => palamndata['size'],:class=>palamndata['class'],
            :onchange=>palamndata['onchange'],:tabindex=>palamndata['tabindex']})

        end
        retstr << hidden_field(gname,"upflg", :value=>1)
        retstr << hidden_field(gname,"MAX_FILE_SIZE", :value=>MAX_FILE_SIZE)
        retstr << hidden_field(gname,"#{name}_pre_f_name", :value=>value)
        retstr << "</div>"
      else
        case(palamndata['viewform'])
        when 'img'
          filepath = "#{palamndata['img_dir']}/#{@cc::getparamdata(palamndata['img_key'],'value')}_#{palamndata['img_flg']}.#{palamndata['ext_ck']}"
          retstr << image_tag(filepath)
        when 'img2'
          unless value==""
            filepath = "/#{IMG_URL}/#{palamndata['img_dir']}/#{@cc::getparamdata(palamndata['img_key'],'value')}_#{palamndata['img_flg']}.#{palamndata['ext_ck']}"
            retstr << "<div id=\"img_box\" style=\"height:#{palamndata['img_h']}px;\" align='center' >#{image_tag(filepath,:height=>"#{palamndata['img_h']}px")}</div>"
          end
        when 'file'
          if palamndata['dl_path'].present? && palamndata['file_exixts?'] === true
            retstr << "#{link_to(h(value),palamndata['dl_path'].merge({:id=>name}))}<br />"
          else
            retstr << "#{value}<br />"
          end
        else
          retstr << "#{value}<br />"
        end
      end
    when 'hidden'
      retstr << hidden_field(gname,name, :value=>value,:onchange=>palamndata['onchange'])
    when 'hiddenv'
      retstr << "<span id=\"v_#{name}\">#{h(value)}</span>"
      retstr << hidden_field(gname,name, :value=>value,:onchange=>palamndata['onchange'])
    when 'view'
      retstr << "<span id=\"v_#{name}\">#{h(value)}</span>"
    else
      retstr << "#{type}"
    end
    unless palamndata['bwd'].nil?
      retstr = retstr + palamndata['bwd']
    end
    unless inputflg == 1
      if !palamndata['link'].nil? && retstr != ""
        id_val = value
        unless palamndata['link'][:id].nil? or @cc.nil?
          id_val = @cc.getparamdata(palamndata['link'][:id],'value')
        end
        retstr = link_to(retstr,{:action=>palamndata['link'][:action],:id=>id_val,:opt=>palamndata['link'][:opt]})
      elsif !palamndata['linkjs'].nil? && retstr != ""
        a_id = (palamndata['a_id'].nil? ? nil : "#{palamndata['a_id']}_#{value}")
        js_val = (palamndata['link_key'].nil? ? value : @cc::getparamdata(palamndata['link_key'],"value"))
        retstr = link_to(retstr.html_safe,"JavaScript:#{palamndata['linkjs']}('#{js_val}','#{palamndata['ajast']}')",:id=>a_id)
      elsif !palamndata['dlink'].nil? && value != ""
        retstr = link_to(palamndata['linktxt'],"#{palamndata['dlink']}?#{value}")
      elsif !palamndata['mail_to'].nil? && value!=""
        retstr = mail_to(value)
      end
      unless palamndata['hiddenData'].nil?
        case type
        when 'select','selectP','textAria','check_one'
          retstr = "<span id='v_#{name}'>#{retstr}</span>"
          retstr << "<input type='hidden' name='#{name}' value='#{value}'>"
        else
          retstr << hidden_field(gname,name, :value=>value)
        end
      end

    end
    unless palamndata['d_id'].nil?
      retstr << "<div id='#{palamndata['d_id']}_#{value}' style='display:none'></div>"
    end

    return retstr.html_safe
  end

  #単純なテーブルを表示する
  
  def printtable(optins={},cc=@cc)
    return "" if cc.nil?
    gname = cc::getgname
    params = cc::getparams
    paramskey = cc::getparamkey
    retstr = ""
    if optins.nil?
      optins = {:not_tbl_tag => false}
    else
      unless optins[:class].nil? then strclass="class=#{optins[:class]}" else strclass="" end
      unless optins[:width].nil? then strwidth="width=#{optins[:width]}" else strwidth="" end
      unless optins[:cellpadding].nil? then cellpadding="#{optins[:cellpadding]}" else cellpadding="3" end
      unless optins[:titletag].nil? then titletag="class=#{optins[:titletag]}" else titletag="class=listTitle" end
      unless optins[:titleid].nil? then titleid="id=\"#{optins[:titleid]}\"" else titleid=nil end
    end
    unless optins[:not_tbl_tag]
      retstr << "<div class=\"listC\">#{essstr(1,1)}は必須項目です。</div>\n" if optins[:not_ess_msg].blank?
      retstr << "<table border=0 cellpadding=#{cellpadding} cellspacing=0 #{strclass} #{strwidth} #{titleid}>\n"
    end
    paramskey.each do |key|
      data = params[key]
      if data['type']=='hidden'
        retstr << "\t#{mkhtmlform(gname,key,data)}\n"
      else
        strclass=''
        retstr << "<tr id=\"row_#{key}\">\n"
        if data['nontitle'].nil?
          str_ess = essstr(data['essFlg'],data['inputFlg'])
          title = data['title']
          unless data['btn_title'].blank?
            title = submit_tag(:button,{:value=>title,:onclick=>data['btn_title'],:type=>"button",:class=>"btn"})
          end
          retstr << "\t<td #{titletag} #{data['span']}>#{title}#{str_ess}</td>\n"
        end
        retstr << "\t<td align=left id=\"#{key}_cell\">#{mkhtmlform(gname,key,data)}</td>\n"
        unless data['sample'].nil? then retstr << "\t<td align=left>#{data['sample']}</td>\n" end
        retstr << "</tr>\n"
      end
    end
    retstr << "</table>\n"  unless optins[:not_tbl_tag]
    return retstr.html_safe
  end
  #入力の１セットを表示する
  def printtable_cellset(key,cc,title_class="listTitle",colspan=nil)
    retstr = content_tag(:td,cc.getparamdata(key,"title"),:class=>title_class)
    retstr << content_tag(:td,mkhtmlform(cc.getgname,key,cc.getparam(key)),:class=>"listL",:colspan=>colspan)
    return retstr.html_safe
  end

  #リストテーブルを表示する
  def printlisttable(voption = {})
    return "" if @cc.nil?
    gname = @cc::getgname
    params = @cc::getparams
    paramskey = @cc::getparamkey
    tbloption = voption[:tbloption].nil? ? ' border=0 cellpadding=0 cellspacing=0 class=soloidline' : voption[:tbloption]
    thclass = voption[:thclass].nil? ? 'listTitle' : voption[:thclass]
    hidstr = ""
    retstr = ""

    retstr << "<table #{tbloption} id='listTbl'>\n"
    retstr << "<tr>\n"
    paramskey.each do |key|
      item = params[key]
      unless item['type'] == 'hidden'
        unless item['sort'].nil?
          if @sort.nil?
            sort="&nbsp;#{link_to('▼',{:sort=>key,:order=>'ASC'},:class=>'sort')}"
          else
            if @sort[:sort] == key
              if @sort[:order]=='DESC'
                sort="&nbsp;#{link_to('▼',{:sort=>key,:order=>'ASC'},:class=>'sort')}"
              else
                sort="&nbsp;#{link_to('▲',{:sort=>key,:order=>'DESC'},:class=>'sort')}"
              end
            else
              sort="&nbsp;#{link_to('▼',{:sort=>key,:order=>'ASC'},:class=>'sort')}"
            end
          end
        else
          sort=""
        end
        thclass=item['tclass'] unless item['tclass'].nil?
        strtitle = item['title']
        if !item['title_len'].nil?
          strtitle = set_char_num(item['title_len'],strtitle,false)
        elsif !voption[:title_char_num].nil?
          strtitle = set_char_num(voption[:title_char_num],strtitle)
        end
        onclick = (key == "ck" ? " onclick=\"ck_box_all(this)\"" : "")
        retstr << "\t<th class=\"#{thclass}\" width=\"#{item['width']}\"#{onclick} >#{strtitle}#{sort}</th>\n"
      end
    end
    retstr << "</tr>\n"
    if @datas.blank?
      retstr << "\t<td class=err colspan=#{paramskey.length.to_s}>#{I18n.t("system_alert.not_fund")}</td>\n"
    else
      rowcount=0
      if paramskey.index("ck").nil?
        tr_option = ""
      else
        tr_option = " onclick='ck_box(this);'"
        if params["ck"]["onclick"].blank?
          params["ck"]["onclick"] = "ck_my_box(this);"
        else
          params["ck"]["onclick"] << "ck_my_box(this);"
        end
      end
      @datas.each do |data|
        row_style = " style=\"#{data["row_style"]}\"" unless data["row_style"].blank?
        cell_alt = data["cell_alt"] unless data["cell_alt"].blank?
        retstr << "<tr#{tr_option}#{row_style}>\n"
        paramskey.each do |key|
          item = params[key]
          item['value']=data[key]
          unless item['link_key'].nil? then js_key=data[item['link_key']] else js_key=data['id'] end
          strclass = item['class']
          unless item['align'].nil? then strclass="list#{item['align']} #{strclass}" end
          if !strclass.blank? && !strclass.index('?').nil?
            strclass = strclass.gsub(/\?/, (rowcount % 2).to_s)
          end
          strclass << " cell_alt" if key == cell_alt
          unless item['type'].blank?
            unless item['type'] == 'hidden'
              retstr << "\t<td class='#{strclass}' >#{mkhtmlform(gname,"#{key}_#{js_key}",item)}</td>\n"
            else
              hidstr << "#{mkhtmlform(gname,"#{key}_#{js_key}",item)}\n"
            end
          end
        end
        retstr << "</tr>\n"
        rowcount+=1
      end
      unless voption[:sum].nil?
        sumdata=voption[:sum]
        retstr << "<tr>\n"
        paramskey.each do |key|
          unless sumdata[key].nil?
            item = params[key]
            item['value']=sumdata[key]
            unless item['align'].nil? then item['class']="list#{item['align']} #{item['class']}" end
            retstr << "\t<td class='#{item['class']}' >#{mkhtmlform(gname,"sum_#{key}",item)}</td>\n"
          else
            retstr << "\t<td>&nbsp;</td>\n"
          end
        end
        retstr << "</tr>\n"
      end
    end
    retstr << "</table>\n"
    retstr << hidstr
    return retstr.html_safe
  end
  #検索テーブル入力の１行を作成
  def mk_serchtable_row(gname,key,params)
    retstr = ""
    data = params[key]
    if data['noserch'].nil? && !data['type'].in?(['hidden', 'hiddenv'])
      retstr << "<tr>\n"
      retstr << "<td class=listL>#{data['title']}</td>\n"
      case data['type']
      when 'textN','textD','textT','textDT'
        if params.has_key?("#{key}_e")
          retstr << "<td class=listL colspan=2>#{mkhtmlform(gname,key,data,1)}～"
          retstr << "#{mkhtmlform(gname,"#{key}_e",params["#{key}_e"],1)}</td>\n"
        else
          retstr << "<td class=listL colspan=2>#{mkhtmlform(gname,key,data,1)}</td>\n"
        end
      when 'textX','textXX','textJ','textKn','textKh','textA','textAA','textURL','textMl','textP'
        criteria_key = "#{key}_cri"
        if params.has_key?(criteria_key)
          retstr << "<td class=listL>#{mkhtmlform(gname,criteria_key,params[criteria_key],1)}</td>\n"
          retstr << "<td class=listL>#{mkhtmlform(gname,key,data,1)}</td>\n"
        else
          retstr << "<td class=listL colspan=2>#{mkhtmlform(gname,key,data,1)}</td>\n"
        end
      when 'select','selectP'
        tmpdata = data['list']
        tmpdata.unshift(SERCH_ALL) if tmpdata.is_a?(Array) && tmpdata.index(SERCH_ALL).nil?
        retstr << "<td class=listL colspan=2>#{mkhtmlform(gname,key,data,1)}</td>\n"
      when 'ckeck_list4list'
        tmpdata = data['list']
        if tmpdata.index(SERCH_ALL).nil? then tmpdata.unshift(SERCH_ALL) end
        data['type']="select"
        retstr << "<td class=listL colspan=2>#{mkhtmlform(gname,key,data,1)}</td>\n"
        data['type']="ckeck_list4list"
      when 'ckeck_list','check_one','radio'
        retstr << "<td class=listL colspan=2>#{mkhtmlform(gname,key,data,1)}</td>\n"
      else
        retstr << "<td class=listC colspan=2><b>#{data['type']}</b></td>\n"
      end
      retstr << "</tr>\n"
    end
    return retstr.html_safe
  end

  #CSV登録説明用テーブルを表示する
  def printcsvtable(cc, cellpadding = 5)
    return "" if cc.nil?
    params = cc::getparams
    paramskey = cc::getparamkey
    retstr = ""
    retstr << "<table border=\"0\" cellpadding=\"#{cellpadding}\" cellspacing=\"0\" class=\"soloidline\">\n"
    retstr << "<tr>\n"
    retstr << "\t<th class=\"listTitle\">＃</th>\n"
    retstr << "\t<th class=\"listTitle\">項目名</th>\n"
    retstr << "\t<th class=\"listTitle\">形式</th>\n"
    retstr << "\t<th class=\"listTitle\">備考</th>\n"
    retstr << "</tr>\n"
    count = 1
    paramskey.each do |key|
      data = params[key]
      strclass=''
      unless data['tclass'].nil?
        strclass=" class='#{data['tclass']}'"
      end
      retstr << "<tr>\n"
      retstr << "\t<td align=\"center\"#{strclass}>#{count}</td>\n"
      retstr << "\t<td nowrap align=\"left\"#{strclass}>#{data['title']}#{essstr(data['essFlg'],1)}</td>\n"
      retstr << "\t<td nowrap align=\"left\">#{getcsvexp(data)}</td>\n"
      if data['exp_option'].nil? || data['exp_option'][:non].nil?
        retstr << "\t<td align=\"left\" #{data['exp_option'][:dt] unless data['exp_option'].nil?}>#{data['exp']}</td>\n"
      end
      retstr << "</tr>\n"
      count +=1
    end
    retstr << "</table>\n"
    return retstr.html_safe
  end
  #CSV登録説明用テーブルを表示する
  def getcsvexp(data)
    return "<b style='color:#FF0000;'>data is balnk</b>" if data.blank?
    retstr=""
    case data['type']
    when 'textN'
      retstr << "半角数字#{data['maxlength']}桁以内"
    when 'textNN'
      retstr << "半角数字#{data['maxlength']}桁以内(マイナス可)"
    when 'textF'
      retstr << "半角数字#{data['maxlength']}桁以内(小数可)"
    when 'textA'
      retstr << "半角英数字#{data['maxlength']}文字以内"
    when 'textAA'
      retstr << "半角英字#{data['maxlength']}文字以内"
    when 'textP','textX'
      retstr << "半角英数字と-ハイフン#{data['maxlength']}文字以内"
    when 'textXX'
      retstr << "半角英数字と一部記号(-_@:)#{data['maxlength']}文字以内"
    when 'textJ'
      retstr << "全角文字#{data['maxlength']}文字以内"
    when 'textKn'
      retstr << "全角カタカナ#{data['maxlength']}文字以内"
    when 'textKh'
      retstr << "半角ｶﾀｶﾅ#{data['maxlength']}文字以内"
    when 'textD'
      retstr << "日付形式(yyyy/mm/dd)"
    when 'textT'
      retstr << "時間形式(HH:ii)"
    when 'textDT'
      retstr << "日付時間形式(yyyy/mm/dd hh:ii)"
    when 'textMl','textMail'
      retstr << "メールアドレス形式"
    when 'textURL'
      retstr << "URL形式"
    when 'textAria'
      retstr << "全角1000文字程度まで"
    when 'select','selectP','radio'
      retstr << "コード(半角数字#{data['maxlength']}桁以内)"
      if data['exp'].nil? then data['exp']='' end
      if !data['list'].nil? && data['ref_flg'].blank?
        strexp=[]
        data['list'].each do |listdata|
          strexp << "#{listdata[1]}:#{listdata[0]}"
        end
        data['exp'] << strexp.join("、")
      end
    when 'ckeck_list'
      retstr << "コード(「|(パイプ)」で囲んだ半角英数字#{data['maxlength']}文字以内)"
      if data['exp'].nil? then data['exp']='' end
      if !data['list'].nil? && data['ref_flg'].blank?
        strexp=[]
        data['list'].each do |listdata|
          strexp << "#{listdata[1]}:#{listdata[0]}"
        end
        data['exp'] << strexp.join("、")
      end
      data['exp'] << "<br />例（|2|3|）"
    when "textColor"
      retstr << "16 進数文字列"
      data['exp'] = "赤=#FF0000、青=#00FF00、緑=#0000FF"
    when 'view','file'
      retstr << "表示のみ"
      data['exp'] = "保存されません。"
    when 'hidden'
      retstr << "システム内固定キーワード"
      data['exp'] = "変更しないでください。新規登録の場合は空白"
    when 'hiddenv'
      retstr << "システム内主キー"
      data['exp'] = "変更しないでください。新規登録の場合は空白"
    else
      retstr << "<b style='color:#FF0000;'>#{data['type']}</b>"
    end
    data['exp'] = "参考データ。表示に使用、データは登録されません。" unless data['ref_flg'].blank?
    return retstr
  end
  #必須マーク
  def essstr(essflg,inputflg)
    return (essflg == 1 && inputflg == 1) ? content_tag(:span,"*",{:class=>"ess"}).html_safe : ""
  end
  #入力チェックのJavaScriptを返す
  def print_input_js()
    retstr = ""
    unless @inck_js.nil? and @inck_js_const.nil?
      retstr << "<script language=\"JavaScript\" type=\"text/JavaScript\">\n"
      retstr << "<!--\n"
      retstr << @inck_js_const unless @inck_js_const.nil?
      unless @inck_js.nil?
        retstr << "function iCheck(fobj){\n"
        retstr << "    strErrorMassage=''\n"
        retstr << @inck_js
        retstr << "    if(strErrorMassage==''){\n"
        retstr << "        return true;\n"
        retstr << "    }else{\n"
        retstr << "        alert(strErrorMassage);\n"
        retstr << "        return false;\n"
        retstr << "    }\n"
        retstr << "}\n"
      end
      retstr << "-->\n"
      retstr << "</script>\n"
    end
    return retstr
  end
  #カンマ編集
  def money_format(num)
    if num.is_a?(Integer)
      strnum = num.to_s
    elsif num.is_a?(String)
      strnum = num
    end
    return (strnum =~ /[-+]?\d{4,}/) ? (strnum.reverse.gsub(/\G((?:\d+\.)?\d{3})(?=\d)/, '\1,').reverse) : num
  end
  #お金単位追加
  def money_unit(num)
    minus = (num.to_i < 0 ? "-":"")
    return I18n.t("unit.amount",:count=>minus+money_format(num.to_s.scan(/\d+/).join))
  end
  #文字列の途中カット
  def str_cut(value,vmaxlength,bwd= "...")
    return "" if value.blank?
    return value if vmaxlength.blank?
    maxl = vmaxlength.to_i
    val_array = value.split(//u)
    if val_array.length > maxl
      return "#{val_array[0..maxl-1].join}#{bwd}"
    else
      return value
    end
  end
  #特定文字数で改行する
  def set_char_num(chernum,value,box_flg = true,str_rn = "<br />")
    ret_a = []
    unless value.blank?
      val_a = value.split(//u)
      chr_count = 0
      val_a.each do |chr|
        ret_a << chr
        chr_count += 1
        if chr_count == chernum
          ret_a << str_rn
          chr_count = 0 if box_flg
        end
      end
    end
    return ret_a.join("").html_safe
  end
  #改行を<br />に変更
  def nl2br(str)
    return "" if str.blank?
    return str.gsub(/\r\n|\r|\n/,"<br />").html_safe
  end
  #Listから文字列を取得する
  def list2str(list,cd)
    list.each{|txt,lcd| return txt if lcd == cd.to_s} unless list.blank?
    return cd
  end
  #指定日時点の年齢を誕生日から算出する
  def get_age(tdate,birth)
    if tdate.blank? || birth.blank? then return "" end
    dates = {"tdate"=>tdate,"birth"=>birth}
    begin
      dates.each{|key,val|
        if val.kind_of?(Date)
        elsif val.kind_of?(String)
          dates[key] = Date.parse(key)
        elsif val.kind_of?(Integer)
            if val.to_s.length == 4
              dates[key] = Date.parse("#{Date.today.year}#{val}")
            elsif val.to_s.length == 8
              dates[key] = Date.parse("#{val}")
            end
        end
      }
    return (dates["tdate"].strftime('%Y%m%d').to_i - dates["birth"].strftime('%Y%m%d').to_i) / 10000
    rescue
      return false
    end
  end
  #ブランクフォーム追加
  def blank_form
    if @evt.nil? || @evt[:language_setting].split(",").length > 1
      return "<td class='blank_form' align=left style='background: #808080;'></td>".html_safe
    else
      return "<td class='blank_form' align=left style='background: #808080;display:none;'></td>".html_safe
    end
  end
end
