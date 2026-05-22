module WkAssignmentHelper
    TblBlock = %w[R M L]
    def get_block_key(str_block)
        return "#{str_block.downcase}_block".to_sym
    end
    #
    def ck_list_to_str(list,value)
        return "" if value.blank?
        tmp_str_a = []
        list.each{|text,val| tmp_str_a << "#{text}" unless value.index("|#{val}|").nil?}
        return tmp_str_a.join("")
    end
    #タイトル部分 title part
    def wk_a_head(def_tbl_setting)
        ret_html = ""
        ret_html << "<div id=\"wkAhead\" class=\"hcaltable\"><div class=\"hcalRow\">\n"
        TblBlock.each.with_index{|block,index|
            
            ret_html << "<div class=\"hcalCell#{" toggle" if index==2}\"><div id=\"wkAheadCell#{block}\"><div id=\"wkAhead#{block}\" class=\"hcaltable\">"
            ret_html << "<div class=\"hcalRow\">\n"
            
            def_tbl_setting[get_block_key(block)].each{|rkey|
                row = def_tbl_setting[rkey]
                title=(row[:title].present? ? row[:title] : Cargo.human_attribute_name(rkey)) 
                #onclick=\"wkASetMachine(this,false);\" ondblclick=\"wkASetLock(this);\"
                ret_html << content_tag(:div,title,:class=>"hcalCell hcalVCell hcalTitleCell",
                    :id=>"wkAhead_#{rkey}",:onclick => (row[:col].blank? ? nil : "obsWkASelectCol(window,event,this)"),
                    :ondblclick => (row[:col].blank? ? nil : "wkALockCol(this)")) + "\n"
            }
            ret_html << "</div></div></div></div>\n"
        }
        ret_html << "</div></div>"
        return ret_html.html_safe
    end
    #メイン部分 main part
    def wk_a_body(def_tbl_setting,cargo,wokers,woker_nmaes,machines,machine_names,branches)
        ret_html = "" ; @conf_flg=1; @lock_flg = false
        block_html = {}
        ret_html << "<div id=\"wkAbody\" class=\"hcaltable\"><div class=\"hcalRow\" >\n"
        TblBlock.each{|block| block_html[get_block_key(block)] = ""}
        cargo.each_with_index{|data_row,row_index|
            cargo_assignment_list = data_row.get_assignment_list
            @conf_flg = 0 if data_row[:conf_flg] != 1
            @lock_flg = true if data_row[:lock_flg] == 1
            TblBlock.each{|block|
                block_key = get_block_key(block)
                block_html[block_key] << "<div class=\"hcalRow\" id=\"wkAbody#{block}_row_#{row_index}\">\n"
                def_tbl_setting[get_block_key(block)].each{|rkey|
                    row_setting = def_tbl_setting[rkey]
                    cell_html = ""
                    case rkey
                    when :r_block,:m_block,:l_block
                        #スキップ skip
                    when :no
                        cell_html = "#{data_row[:work_no]}"
                        cell_html << hidden_field("cargo_#{row_index}","id",:value => data_row[:id])
                        cell_html << hidden_field("cargo_#{row_index}","work_class",:value => data_row[:work_class])
                        cell_html << hidden_field("cargo_#{row_index}","move_no",:value => data_row[:move_no])
                        cell_html << hidden_field("cargo_#{row_index}","cargo_name",:value => data_row[:cargo_name])
                        cell_html << hidden_field("cargo_#{row_index}","work_place",:value => data_row[:work_place])
                        cell_html << hidden_field("cargo_#{row_index}","work_no",:value => data_row[:work_no])
                    when :work_name
                        cell_html = (data_row[rkey].blank? ? "&nbsp;" : "<span class='trigger_#{row_index} wc_#{data_row[:work_class]}'>#{data_row[rkey]}</span>")
                        cell_html << "<div class=\"listR\">"
                        cell_html << link_to(icon("fas","triangle-exclamation"),"JavaScript:wkAErrorMsgView(#{row_index},'block')",:id=>"ErrorMsgBtn#{row_index}",:class=>"err",:style=>"display:none;")
                        cell_html << content_tag(:div,nil,:class=>"wkAInfoBox wkAErrorMsgBox",:id=>"ErrorMsgBox#{row_index}",:onclick=>"wkAErrorMsgView(#{row_index},'none')")
                        cell_html << "<div class=\"radiobox\" style=\"margin-right:5px;\">\n"
                        cell_html << radio_button("cargo_#{row_index}",:esta_flg,1,{:checked=>(data_row[:esta_flg].to_i < 2) ,:class=>"radiobutton"})
                        cell_html << content_tag(:label,"中",:for=>"cargo_#{row_index}_esta_flg_1")
                        cell_html << radio_button("cargo_#{row_index}",:esta_flg,2,{:checked=>(data_row[:esta_flg] == 2) ,:class=>"radiobutton"})
                        cell_html << content_tag(:label,"成",:for=>"cargo_#{row_index}_esta_flg_2")
                        cell_html << radio_button("cargo_#{row_index}",:esta_flg,9,{:checked=>(data_row[:esta_flg] == 9) ,:class=>"radiobutton"})
                        cell_html << content_tag(:label,"不",:for=>"cargo_#{row_index}_esta_flg_9")
                        cell_html << "</div>"
                        cell_html << link_to(icon("fas","pen-to-square"),"JavaScript:wkAMsgRowView(#{row_index})")
                        cell_html << "</div>"
                    when :cargo_name
                        cell_html = (data_row[rkey].blank? ? "&nbsp;" : data_row[rkey])
                        tmp_text = list2str(CargoRequest::IOFlg,"#{data_row[:io_flg]}")
                        tmp_text = "" if tmp_text = "0"
                        cell_html << content_tag(:div,tmp_text,:class=>"ioAlert")
                    when :work_place
                        cell_html = (data_row[rkey].blank? ? "&nbsp;" : data_row[rkey])
                        tmp_text = (data_row[:dirt_flg] == 1 ? "汚れ" : "")
                        cell_html << content_tag(:div,tmp_text,:class=>"allowanceAlert")
                    when :mc
                        cell_html << "<table class=\"wkATbl\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\">"
                        str_val = data_row["momo_#{rkey}"]
                        # cell_html << "<tr class=\"\" ><td>"
                        # cell_html << (data_row[:machine_nm].blank? ? "&nbsp;" : data_row[:machine_nm])
                        # cell_html << "</td></tr>"
                        cell_html << "<tr class=\"\" ><td>"
                        cell_html << mk_assignment_tbl(row_index,rkey,data_row,row_setting[:col],cargo_assignment_list[rkey.to_s],woker_nmaes,machine_names)
                        cell_html << "</td></tr>"
                        cell_html << "</table>\n"
                    when :fm,:dm,:wi,:dr,:wk
                        cell_html = mk_assignment_tbl(row_index,rkey,data_row,row_setting[:col],cargo_assignment_list[rkey.to_s],woker_nmaes,machine_names)
                    when :s_time
                        value = data_row[rkey].is_a?(Time) ? data_row[rkey].strftime("%H:%M") : ""
                        cell_html << text_field("cargo_#{row_index}","#{rkey}",
                                        {:size => 4,:maxlength => 5,:class=>"wkAtimeField" ,:value=>value,:onchange=>"set_time(this); calcWorkTime(this);"})
                        cell_html << "<br />"
                        value = data_row[:e_time].is_a?(Time) ? data_row[:e_time].strftime("%H:%M") : ""
                        cell_html << text_field("cargo_#{row_index}","#{:e_time}",
                                        {:size => 4,:maxlength => 5,:class=>"wkAtimeField" ,:value=>value,:onchange=>"set_time(this); calcWorkTime(this);"})
                        cell_html << hidden_field("cargo_#{row_index}","work_time",:value => data_row[:work_time])
                        cell_html << hidden_field("cargo_#{row_index}","orver_time",:value => data_row[:orver_time])
                    when :i_time
                        value = data_row[rkey].is_a?(Time) ? data_row[rkey].strftime("%H:%M") : ""
                        cell_html << text_field("cargo_#{row_index}","#{rkey}",
                                        {:size => 4,:maxlength => 5,:class=>"wkAtimeField" ,:value=>value,:onchange=>"set_time(this); calcWorkTime(this);"})
                    when :np
                        value = data_row[:rk_np] || ""
                        cell_html << "労供:" + text_field("cargo_#{row_index}","rk_np",{:size => 2,:maxlength => 2,:class=>"wkAtimeField", :value=>value})
                        cell_html << content_tag(:div,nil,:id=>"wkACargoNp_#{row_index}")
                        cell_html << hidden_field("cargo_#{row_index}","ob_np",:value => data_row[:ob_np])
                        cell_html << hidden_field("cargo_#{row_index}","hh_np",:value => data_row[:hh_np])
                    when :wk_np
                        wk_w = data_row.get_wk_w
                        cell_html << content_tag(:div,wk_w.to_s,:id=>"wkACargoWkNp_#{row_index}")
                        # cell_html << content_tag(:div,data_row[rkey].blank? ? "0" : data_row[rkey],:id=>"wkACargoWkNp_#{row_index}")
                        cell_html << hidden_field("cargo_#{row_index}",rkey,:value => data_row[:rkey])
                    when :note
                        values = []
                        [:quantity,:note,:matter1,:matter2].each{|sub_key|
                            values << data_row[sub_key] unless data_row[sub_key].blank?
                        }
                        if values.blank?
                          cell_html = "&nbsp;"
                        else
                          cell_html = ""
                          cell_html << link_to(icon("far","comment"),"JavaScript:wkANoteBoxView(#{row_index})")
                          cell_html << "<br />"
                          cell_html << content_tag(:div,values.join("<br />").html_safe,:id=>"noteBox_#{row_index}",:style=>"display:none;")
                        end
                    else
                        cell_html = "#{rkey} is undefined"
                    end
                    unless cell_html.blank?
                        block_html[block_key] << content_tag(:div,cell_html.html_safe,
                            :class=>"hcalCell hcalVCell #{(row_setting[:align].present? ? "list#{row_setting[:align]}" : "")}",
                            :id=>"wkAbody_#{rkey}_#{row_index}",:onclick => (rkey==:no ? "obsWkASelectRow(window,event,this)" : nil),
                            :ondblclick => (rkey==:no ? "wkALockRow(this)" : nil)) + "\n"
                    end
                }
                block_html[block_key] << "</div >"
            }
        }unless cargo.blank?
        TblBlock.each.with_index{|block,index|
            ret_html << "<div class=\"hcalCell#{" toggle" if index==2}\"><div id=\"wkAbodyCell#{block}\" onscroll=\"doWkABodyScroll(this);\"><div id=\"wkAbody#{block}\" class=\"hcaltable\">\n"
            ret_html << block_html[get_block_key(block)] 
            ret_html << "</div></div></div>\n"
        }

        ret_html << "</div></div>\n"  #wkAbody hcaltable,hcalRow
        return ret_html.html_safe
    end
    #配番設定テーブル Assignment setting table
    def mk_assignment_tbl(box_index,rkey,data_row,col_num,assignment_list,woker_nmaes,machine_names)
        need_count = {}
        max_count = 0
        wk_date = data_row[:work_date]
        unless rkey==:mc
            Cargo::WkTypeXNumKey[rkey].each{|ckey|
                # UAT-31 | if :mcの場合、max_countとneed_countは1固定 UAT-31 | If :mc is used, max_count and need_count are fixed at 1.
                if data_row[ckey].present? && data_row[ckey] > 0
                    max_count += data_row[ckey] # cargos作業必要人数取得 Obtaining the required number of personnel for cargo handling operations.
                    need_count[ckey[0..1]] ||= 0
                    need_count[ckey[0..1]] += data_row[ckey]
                end
            }
        else
            need_count["mc"] = data_row[:machine_nm].present? ? 1 : 0
            max_count +=1
        end
        str_need_count=[] ; str_need_count = need_count.map{|key,num| "#{key.upcase}:#{num}"} unless need_count.blank?


        # -- UAT152(描画行数はwork_indexに依存させる) --- UAT152 (The number of lines to be drawn depends on work_index)
        # row_max -> 機械行、作業員行のペアを1行とした描画行数 row_max -> Number of rows to draw, where a pair of machine row and worker row is considered one row.
        worker_assignment_list, machine_assignment_list = assignment_list.values_at(:worker,:machine);
        worker_wk_indexs  = worker_assignment_list.keys.map(&:to_i);
        machine_wk_indexs = machine_assignment_list.keys.map(&:to_i);
        max_wk_index      = [worker_wk_indexs.max.to_i, machine_wk_indexs.max.to_i].max.to_i;

        # 表示行数の計算 Calculation of the number of display lines
        row_max = 1;
        if max_wk_index>0
            row_max = (max_wk_index.to_f / col_num.to_f).ceil # 必要人数/改行人数 Required number of people/number of line breaks
            row_max = 1 if row_max == 0 
            # row_max += 1 if rkey==:wk && (max_count.to_f % col_num.to_f) > 5
            # row_max = [row_max,str_need_count.size].max if [:wi,:dr].include?(rkey) # 機械種別ごとに行をとる Take a row for each machine type.
        end
        # -- --------------------------------------- ---


        cell_html = ""
        cell_html << "<table class=\"wkATbl\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\" id=\"wkATbl_#{box_index}_#{rkey}\">"
        #注意事項行 Notes line
        str_val = data_row["momo_#{rkey}"]
        cell_html << "<tr id=\"wkAMsgRow_#{box_index}_#{rkey}\" class=\"wkAMsgRow\" #{(str_val.blank? ? " style=\"display:none\"" : "")}><td colspan=\"#{col_num}\">"
        cell_html << text_field("cargo_#{box_index}","momo_#{rkey}",{:style=>"width:96%;",:maxlength => 128,:class=>"wkAnoteField wkAnoteField#{rkey}" ,:value=>str_val})
        cell_html << "</td></tr>"
        1.upto(row_max){|row_index|
            #機械行 Machine line
            unless rkey==:fm
                cell_html << "<tr class=\"wkACargoMachineRow\" >"
                col_num.times{|wi|
                    wk_index = (row_index-1)*col_num + wi + 1
                    machine = (assignment_list[:machine].has_key?(wk_index) ? assignment_list[:machine][wk_index] : {})
                    str_class = "wkAPanel"
                    # str_class << " wkAPanelock" if machine[:lock_flg].to_i==1
                    cell_html << "<td>"
                    cell_html << "<div class=\"#{str_class}\" id=\"wkACargoMachine_#{box_index}_#{rkey}_#{wk_index}\" onclick=\"obsWkASetMachine(window,event,this,false);\" ondblclick=\"obsWkASetLock(window,event,this);\">"
                    # cell_html << "<div class=\"#{str_class}\" id=\"wkACargoMachine_#{box_index}_#{rkey}_#{wk_index}\" onclick=\"wkASetMachine(this,false);\" ondblclick=\"wkASetLock(this);\">"
                    cell_html << content_tag(:span,"#{machine_names[machine[:machine_cd]]}",:id=>"wkACargoMachine_#{box_index}_#{rkey}_#{wk_index}_text")
                    cell_html << hidden_field("wkACargoMachine_#{box_index}","#{rkey}_#{wk_index}_machine_id",:value => machine[:machine_id])
                    cell_html << hidden_field("wkACargoMachine_#{box_index}","#{rkey}_#{wk_index}_machine_cd",:value => machine[:machine_cd])
                    cell_html << hidden_field("wkACargoMachine_#{box_index}","#{rkey}_#{wk_index}_m_type",:value => machine[:m_type])
                    cell_html << hidden_field("wkACargoMachine_#{box_index}","#{rkey}_#{wk_index}_work_time",:value => machine[:work_time])
                    cell_html << hidden_field("wkACargoMachine_#{box_index}","#{rkey}_#{wk_index}_lock_flg",:value => machine[:lock_flg]) #if machine.has_key?(:lock_flg)
                    cell_html << hidden_field("wkACargoMachine_#{box_index}","#{rkey}_#{wk_index}_work_index",:value => machine[:work_index])
                    if machine.has_key?(:maintenanc_type)
                      cell_html << hidden_field("wkACargoMachine_#{box_index}","#{rkey}_#{wk_index}_maintenanc_type",:value => machine[:maintenanc_type]) 
                      cell_html << hidden_field("wkACargoMachine_#{box_index}","#{rkey}_#{wk_index}_e_date",:value => machine[:e_date]) 
                      cell_html << hidden_field("wkACargoMachine_#{box_index}","#{rkey}_#{wk_index}_note",:value => machine[:note]) 
                    else
                      cell_html << hidden_field("wkACargoMachine_#{box_index}","#{rkey}_#{wk_index}_maintenanc_type",:value => nil) 
                      cell_html << hidden_field("wkACargoMachine_#{box_index}","#{rkey}_#{wk_index}_e_date",:value => nil) 
                      cell_html << hidden_field("wkACargoMachine_#{box_index}","#{rkey}_#{wk_index}_note",:value => nil) 
                    end
                    cell_html << "</div></td>"
                }
                cell_html << "</tr>"
            end
            #作業員行 Worker line
            # UAT-31 | :mcはスキップ UAT-31 | :mc is skipped

            unless rkey==:mc
                cell_html << "<tr class=\"wkACargoWorkerRow\" >"
                col_num.times{|wi|
                    wk_index = (row_index-1)*col_num + wi + 1
                    worker = (assignment_list[:worker].has_key?(wk_index) ? assignment_list[:worker][wk_index] : {})
                    str_class = "wkAPanel"
                    # str_class << " wkAPanelock" if worker[:lock_flg].to_i == 1
                    # str_class << " wkAPanelOver" if max_count < wk_index
                    cell_html << "<td>"
                    cell_html << "<div class=\"#{str_class}\" id=\"wkACargoWorker_#{box_index}_#{rkey}_#{wk_index}\" onclick=\"obsWkASetWorker(window,event,this,false)\" ondblclick=\"obsWkASetLock(window,event,this);\">"
                    # cell_html << "<div class=\"#{str_class}\" id=\"wkACargoWorker_#{box_index}_#{rkey}_#{wk_index}\" onclick=\"alert('bow');wkASetWorker(this,false)\" ondblclick=\"wkASetLock(this);\">"
                    cell_html << content_tag(:span,"#{woker_nmaes[worker[:login_id]]}",:id=>"wkACargoWorker_#{box_index}_#{rkey}_#{wk_index}_text")
                    cell_html << hidden_field("wkACargoWorker_#{box_index}","#{rkey}_#{wk_index}_user_id",:value => worker[:user_id])        #作業員の内部ID Worker's internal ID
                    cell_html << hidden_field("wkACargoWorker_#{box_index}","#{rkey}_#{wk_index}_login_id",:value => worker[:login_id])      #作業員のログインID Worker's login ID
                    cell_html << hidden_field("wkACargoWorker_#{box_index}","#{rkey}_#{wk_index}_work_index",:value => worker[:work_index])  #作業員の作業順 Worker's work order
                    cell_html << hidden_field("wkACargoWorker_#{box_index}","#{rkey}_#{wk_index}_bus_flg",:value => worker[:bus_flg])        #バスフラグ：→作業時間に影響 Bus flag: → Affects work time
                    cell_html << hidden_field("wkACargoWorker_#{box_index}","#{rkey}_#{wk_index}_work_class",:value => worker[:work_class])  #作業区分：1:本船,2:沿岸 Work classification: 1: Onboard vessel, 2: Coastal work
                    cell_html << hidden_field("wkACargoWorker_#{box_index}","#{rkey}_#{wk_index}_wk_class",:value => worker[:wk_class])      #担当作業：fm_mとかbl_sとか Assigned tasks: fm_m, bl_s, etc.
                    cell_html << hidden_field("wkACargoWorker_#{box_index}","#{rkey}_#{wk_index}_competence",:value => worker[:competence])  #力量 competence
                    cell_html << hidden_field("wkACargoWorker_#{box_index}","#{rkey}_#{wk_index}_s_time",:value => worker[:s_time])          #開始時刻 Start time
                    cell_html << hidden_field("wkACargoWorker_#{box_index}","#{rkey}_#{wk_index}_e_time",:value => worker[:e_time])          #終了時刻 End time
                    cell_html << hidden_field("wkACargoWorker_#{box_index}","#{rkey}_#{wk_index}_work_time",:value => worker[:work_time])    #法定作業時間（分） Statutory working hours (minutes)
                    cell_html << hidden_field("wkACargoWorker_#{box_index}","#{rkey}_#{wk_index}_orver_time",:value => worker[:orver_time])  #法定残業時間（分） Statutory overtime hours (minutes)
                    cell_html << hidden_field("wkACargoWorker_#{box_index}","#{rkey}_#{wk_index}_p_work_time",:value => -1)   #所定作業時間（分） Standard working time (minutes)
                    cell_html << hidden_field("wkACargoWorker_#{box_index}","#{rkey}_#{wk_index}_p_orver_time",:value => -1)  #所定残業時間（分） Standard overtime hours (minutes)
                    cell_html << hidden_field("wkACargoWorker_#{box_index}","#{rkey}_#{wk_index}_lock_flg",:value => worker[:lock_flg])      #作業員のロックフラグ Worker lock flag
                    cell_html << hidden_field("wkACargoWorker_#{box_index}","#{rkey}_#{wk_index}_base_no",:value => worker[:base_no])        #作業員の前日までの累積残業（月) Cumulative overtime for workers up to the previous day (monthly)
                    cell_html << "</div></td>"
                }
                cell_html << "</tr>"
            end
        }
        cell_html << "</table>\n"
        if rkey!=:mc
            cell_html << content_tag(:div,"#{str_need_count.join(" ")}",:class=>"ioAlert addPanelRowBtn",:onclick=>"obsWkACargoAddPanelRow(window,null,'wkATbl_#{box_index}_#{rkey}');")
        else
            cell_html << content_tag(:div,data_row[:machine_nm] || "",:class=>"ioAlert mcNm")
        end
        need_count.each{|key,count|
          cell_html << hidden_field("needCount_#{box_index}_#{rkey}","#{key}",:value => count)
        }
        return cell_html
    end
    #フッタ部分-ボタン、パレットリスト Footer section - Buttons, Palette list
    
    def wk_a_foot(wokers,machines,branches,msgs,vacation_types)
        absentees = {} ; vacation_types.each_key{|base_no| absentees[base_no] = []}; absentees["6"]={"1"=>[],"0"=>[]};
        ret_html = ""
        ret_html << "<div id=\"wkAfoot\">\n"
        #ボタン button
        ret_html << "<div id=\"wkAButtons\"><div class=\"hcaltable\" style=\"width:98%\"><div class=\"hcalRow\">\n"
        ret_html << "<div class=\"hcalCell listL\">"
        ret_html << submit_tag(:button, :value=>'作業員',:type=>'button',:onclick=>"wkAChangeViewWokerGroup('1');",:class=>"wkABtn") + "\n"
        ret_html << submit_tag(:button, :value=>'機械',:type=>'button',:onclick=>"wkAChangeViewMachineGroup('ld')",:class=>"wkABtn")  + "\n"
        ret_html << submit_tag(:button, :value=>'休み',:type=>'button',:onclick=>"wkAViewPanelList('Absentee')",:class=>"wkABtn")  + "\n"
        ret_html << "</div>"

        # -----------表示グループ切替----------------------- Display group switching
        ret_html << "<div class=\"viewselectbutton-wrapper\">"

            # 表示切替（作業員グループ
            #ret_html << "<div class=\"hcalCell listL wokergroup-selectbutton-outer active\">"
            #ret_html << ""
            #branches.each{|cd,bdata|
            #    next unless %w(1 2 3 4).include?(cd)
            #    branch_name = bdata[:name]
            #    ret_html << submit_tag(:button, :value=>branch_name,:type=>'button',:onclick=>"wkAChangeViewWokerGroup('#{cd}')",:class=>"wkABtn wkABranche#{cd}") + "\n"
            #}
            #ret_html << submit_tag(:button, :value=>"その他",:type=>'button',:onclick=>"wkAChangeViewWokerGroup('5')",:class=>"wkABtn") + "\n"
            #ret_html << "</div>"

            # 表示切替（機械種別
            #ret_html << "<div class=\"hcalCell listL machinegroup-selectbutton-outer\">"
            #ret_html << ""
            #machines.each{|m_type,m_list|
            #    machine_nm = list2str(Machine::MType,m_type)
            #    ret_html << submit_tag(:button, :value=>machine_nm,:type=>'button',:onclick=>"wkAChangeViewMachineGroup('#{m_type}')",:class=>"wkABtn wkAMachineType_#{m_type}") + "\n"
            #}
            #ret_html << "</div>"
        ret_html << "</div>"


        ret_html << "<div class=\"hcalCell listC\">"
        unless @lock_flg || !@can_edit
          ret_html << submit_tag(:button, :value=>'FM前CP',:type=>'button',:onclick=>"return wkAConfirmCloseSubWindow() && wkADoCreate('copyFM');",:class=>"wkABtn")  + "\n"
          ret_html << submit_tag(:button, :value=>'DM前CP',:type=>'button',:onclick=>"return wkAConfirmCloseSubWindow() && wkADoCreate('copyDM');",:class=>"wkABtn")  + "\n"
        end
        ret_html << submit_tag(:button, :value=>'はがす',:type=>'button',:onclick=>"obsWkAUnSetAssignment(window,null);",:class=>"wkABtn",:id=>"wkAUnSetAssignmentBtn")  + "\n"
        ret_html << "</div>"
        ret_html << "<div class=\"hcalCell listR\">"
        unless @lock_flg || !@can_edit
          ret_html << submit_tag(:button, :value=>'自動配番',:type=>'button',:onclick=>"return wkAConfirmCloseSubWindow() && wkADoCreate('mkAssignment');",:class=>"wkABtn btnAutoAssignment")  + "\n"
        end
        ret_html << submit_tag(:button, :value=>'臨時等表示',:type=>'button',:onclick=>"switchViewMode(event,this);",:class=>"wkABtn")  + "\n"
        ret_html << "<div class=\"checkboxBtn\" style=\"margin-right:10px;\">"
        ret_html << check_box_tag(:conf_flg,"1",@conf_flg==1,:class=>"btn")
        ret_html << content_tag(:label,"配番確定",:for=>:conf_flg)
        ret_html << "</div>"

        if @lock_user.blank? && @can_lock
            ret_html << submit_tag(:button, :value=>'ロック',:type=>'button',:onclick=>"wkACargoLock(this)",:class=>"wkABtn")  + "\n"
        elsif @lock_user.present?
            ret_html << submit_tag(:button, :value=>'ロック中',:disabled=>true,:type=>'button',:onclick=>"return false;",:class=>"wkABtn")  + "\n"
        else
            ret_html << submit_tag(:button, :value=>'ロック',:disabled=>true,:type=>'button',:onclick=>"return false;",:class=>"wkABtn")  + "\n"
        end

        if @lock_flg
          ret_html << submit_tag(:button, :value=>'実績登録済みのため変更不可',:disabled=>true,:type=>'button',:onclick=>"return false;",:class=>"wkABtn")  + "\n"
        elsif !@can_edit
          ret_html << submit_tag(:button, :value=>'配番作業中のため変更不可',:disabled=>true,:type=>'button',:onclick=>"return false;",:class=>"wkABtn")  + "\n"
        else
          ret_html << submit_tag(:button, :value=>'保存',:type=>'button',:onclick=>"wkAConfirmSave(this)",:class=>"wkABtn")  + "\n"
        end
        
        ret_html << "</div>"
        ret_html << "</div></div></div>\n"
        #作業員パネル worker panel
        ret_html << "<div id=\"wkAWorkers\"><div class=\"hcaltable\">\n"
        branches.each{|cd,bdata|
            next if wokers[cd].blank?
            ret_html << "<div id=\"brancheRow#{cd}\" class=\"hcalRow\">"
            ret_html << content_tag(:div,bdata[:name],:class=>"hcalCell hcalVCell wkAWorkerTitle wkABranche#{cd}")
            ret_html << "<div class=\"hcalCell hcalVCell \">"
            wokers[cd].each{|udata|
                str_class="wkAPanel "
                if udata[:vacation].present?
                    bn = udata[:vacation][:base_no]
                    if bn == 2 || bn == 31 || bn == 32 || bn == 33 || bn == 34 || bn == 41 || bn == 42 ||\
                        (udata[:vacation][:base_no] == 6 && udata[:vacation][:at_work]==1)
                        str_class << " wkABranche#{cd}"
                    else
                        str_class << " wkAIsHoliday"
                    end
                    if udata[:vacation][:base_no] == 6
                      if udata[:vacation][:at_work]==1
                        absentees["#{udata[:vacation][:base_no]}"]["1"] << udata
                      else
                        absentees["#{udata[:vacation][:base_no]}"]["0"] << udata
                      end
                      
                    else
                      absentees["#{udata[:vacation][:base_no]}"] << udata
                    end
                else
                    str_class << " wkABranche#{cd}"
                end
                ret_html << "<div class=\"#{str_class}\" id=\"wkAUser_#{udata[:login_id]}\" onclick=\"obsWkASelectUser(window,event,this)\" >"
                # ret_html << "<div class=\"#{str_class}\" id=\"wkAUser_#{udata[:login_id]}\" onclick=\"wkASelectUser(this)\" >"
                ret_html << udata[:s_name]
                udata.each{|ukey,uval|
                    if ukey == :vacation
                        uval = {} if uval.blank?
                        ret_html  << hidden_field("wkAUser_#{udata[:login_id]}",:vacation_type_id,:value => uval[:vacation_type_id])
                        ret_html  << hidden_field("wkAUser_#{udata[:login_id]}",:base_no,:value => uval[:base_no])
                        ret_html  << hidden_field("wkAUser_#{udata[:login_id]}",:at_work,:value => uval[:at_work])
                        ret_html  << hidden_field("wkAUser_#{udata[:login_id]}",:arriv_time,:value => uval[:arriv_time])
                        ret_html  << hidden_field("wkAUser_#{udata[:login_id]}",:leav_time,:value => uval[:leav_time])

                        vacation_info = ""
                        vacation_info << "#{vacation_types["#{uval[:base_no]}"]}"
                        case uval[:base_no]
                        when 2,3,31,32,33,34,41,42 ;  vacation_info << "(#{uval[:arriv_time]}～"; vacation_info << "#{uval[:leav_time]})";
                        when 6 ; vacation_info << "(#{list2str(KAFUKA_MARK,"#{uval[:at_work]}")})"
                        when 7,17 ; vacation_info << "(#{uval[:origin_date].try(:strftime,"%m/%d")})"
                        end
                        ret_html  << hidden_field("wkAUser_#{udata[:login_id]}",:vacation_info,:value => vacation_info)
                    else
                        ret_html  << hidden_field("wkAUser_#{udata[:login_id]}",ukey,:value => uval)
                    end
                }unless udata.blank?
                if udata.present?
                    ret_html << hidden_field("wkAUser_#{udata[:login_id]}","assignments",:value => nil)
                    msg = (msgs.has_key?(udata[:login_id]) ? msgs[udata[:login_id]] : {})
                    ret_html << hidden_field("wkAUser_#{udata[:login_id]}","msg",:value => msg[:msg])
                    ret_html << hidden_field("wkAUser_#{udata[:login_id]}","created_uname",:value => msg[:created_uname])
                end
                ret_html << "</div>\r\n"
            }
            ret_html << "</div></div>"
        }unless branches.blank?
        ret_html << "</div></div>\n"
        #機械パネル mechanical panel
        ret_html << "<div id=\"wkAMachines\"><div class=\"hcaltable\">\n"
        today = Date.today
        machines.each{|m_type,m_list|
            ret_html << "<div class=\"hcalRow\">"
            ret_html << content_tag(:div,list2str(Machine::MType,m_type),:class=>"hcalCell hcalVCell wkAMachineTitle wkAMachineType_#{m_type}")
            ret_html << "<div class=\"hcalCell hcalVCell \">"
            m_list.each{|mdata|
                str_class="wkAPanel "
                if mdata[:mainte].present?
                  str_class << " wkAIsHoliday"  
                elsif mdata[:color].present?
                  str_class << " wkAMachineBGC#{mdata[:color].gsub("#","")}"
                else
                  str_class << " wkABranche#{mdata[:branch_cd]}"
                end
                if mdata[:u_maintenance] == 1
                  ret_html << "<div class=\"#{str_class}\" id=\"wkAMachine_#{mdata[:id]}\" style=\"display:none;\">"
                else
                  ret_html << "<div class=\"#{str_class}\" id=\"wkAMachine_#{mdata[:id]}\" onclick=\"obsWkASelectMachine(window,event,this)\">"
                #   ret_html << "<div class=\"#{str_class}\" id=\"wkAMachine_#{mdata[:id]}\" onclick=\"wkASelectMachine(this)\">"
                end
                ret_html << mdata[:name]
                mdata.each{|mkey,mval|
                    case mkey
                    when :mainte
                        if mval.blank?
                            maintenance = ""
                        else
                            maintenance = "#{list2str(MachineMaintenance::MaintenancType,"#{mval[:maintenanc_type]}")}"
                            maintenance << "#{mval[:s_date].try(:strftime,"%y/%m/%d")}～#{mval[:e_date].try(:strftime,"%m/%d")}" 
                            maintenance << "#{mval[:note]}" 
                        end
                        ret_html  << hidden_field("wkAMachine_#{mdata[:id]}",:maintenance,:value => maintenance)
                    when :schedule
                        if mval.blank?
                            schedule = ""
                        else
                            schedule = mval.join("<br />")
                        end
                        ret_html  << hidden_field("wkAMachine_#{mdata[:id]}",:schedule,:value => schedule)
                    when :start_day
                        if mval.blank?
                            period = ""
                        else
                            age_y = today.year - mval.year
                            age_m = today.month - mval.month - 1
                            if age_m < 0
                              age_y -=1
                              age_m = 12 + age_m
                            end
                            strage = ""
                            strage << "#{age_y}年" if age_y > 0
                            strage << "#{age_m}ヵ月"
                            period = "#{mval.strftime("%Y/%m/%d")}より#{strage}"
                        end
                        ret_html  << hidden_field("wkAMachine_#{mdata[:id]}",:period,:value => period)
                    else
                        ret_html  << hidden_field("wkAMachine_#{mdata[:id]}",mkey,:value => mval)
                    end
                }
                ret_html  << hidden_field("wkAMachine_#{mdata[:id]}","assignments",:value => nil)
                ret_html << "</div>\r\n"
            }unless m_list.blank?
            ret_html << "</div></div>"
        }
        ret_html << "</div></div>\n"
        #欠勤者パネル Absentee Panel
        ret_html << "<div id=\"wkAAbsentee\"><div class=\"hcaltable\">\n"
        absentees_html = ""
        vacation_types.each{|base_no,title|
            next if absentees[base_no].blank?
            if base_no=="6"
                unless absentees[base_no]["1"].blank?
                    absentees_html << "<div class=\"hcalRow\">"
                    absentees_html << content_tag(:div,"#{title}○",:class=>"hcalCell hcalVCell wkAMachineTitle")
                    absentees_html << "<div class=\"hcalCell hcalVCell \">"
                    absentees[base_no]["1"].each{|udata|
                        absentees_html << content_tag(:div,udata[:s_name],:class=>"wkAPanel wkABranche#{udata[:branch_cd]}")
                    }
                    absentees_html << "</div></div>"
                end
                unless absentees[base_no]["0"].blank?
                    absentees_html << "<div class=\"hcalRow\">"
                    absentees_html << content_tag(:div,"#{title}×",:class=>"hcalCell hcalVCell wkAMachineTitle")
                    absentees_html << "<div class=\"hcalCell hcalVCell \">"
                    absentees[base_no]["0"].each{|udata|
                        absentees_html << content_tag(:div,udata[:s_name],:class=>"wkAPanel wkABranche#{udata[:branch_cd]}")
                    }
                    absentees_html << "</div></div>"
                end
            else
                absentees_html << "<div class=\"hcalRow\">"
                absentees_html << content_tag(:div,title,:class=>"hcalCell hcalVCell wkAMachineTitle")
                absentees_html << "<div class=\"hcalCell hcalVCell \">"
                absentees[base_no].each{|udata|
                    absentees_html << content_tag(:div,udata[:s_name],:class=>"wkAPanel wkABranche#{udata[:branch_cd]}")
                }
                absentees_html << "</div></div>"
            end
        }
        if absentees_html.blank?
            ret_html << content_tag(:div,content_tag(:div,"なし",:class=>"hcalCell hcalVCell ",:style=>"width:300px;padding:10px;"),:class=>"hcalRow")
        else
            ret_html << absentees_html
        end
        ret_html << "</div></div>\n"

        ret_html << "</div>\n"
        return ret_html.html_safe

    end
end