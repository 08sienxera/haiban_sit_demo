# encoding: utf-8
class Excel::ArrayTbl < Excel::ExcelClass
  #
  #書式データ生成
  def set_myformat
    @@myformat = {}
    @@myformat[:h] = @workbook.add_format(@font.merge(:bold=>1,:bg_color=>22,:border=>1,:text_wrap=>0))
    @@myformat[:c] = @workbook.add_format(@font.merge(:border=>1,:align=>:left,:text_wrap=>0))
    @@myformat[:a] = @workbook.add_format(@font.merge(:border=>1,:align=>:left,:text_wrap=>1))
    @@myformat[:c_r] = @workbook.add_format(@font.merge(:border=>1,:align=>:right,:text_wrap=>0))
    return @@myformat
  end
  #
  #Ｅｘｃｅｌ出力
  # In:array_data : 2次元配列
  #    header     : １行目ヘッダフラグ
  #    header_lock     : １行目ヘッダ行を固定
  def mk_excel(array_data,header = false,header_lock = false)
    set_myformat()
    worksheet = @workbook.add_worksheet("一覧")
    worksheet.set_paper(9)      #A4サイズ
    worksheet.set_landscape()   #横向き
    worksheet.hide_gridlines()  #余分な罫線の印刷をさせない
    worksheet.set_margins(0.2)  #余白を設定
    worksheet.freeze_panes(1,0) if header_lock
    col_ws = []
    array_data.each_with_index{|datas,row|
      if header && row == 0
        datas.each_with_index{|data,col|
          worksheet.write(row,col,data,@@myformat[:h])
          col_ws[col] = (data.bytesize > 8 ? data.bytesize : 8)
        }unless datas.blank?
      else
        datas.each_with_index{|data,col|
          data_size = 8
          case data.class.name
          when "Fixnum"
            worksheet.write(row,col,data,@@myformat[:c_r])
            data_size = data.bytesize if data.present?
          when "String","NilClass"
            worksheet.write(row,col,data,@@myformat[:c])
            data_size = (data.bytesize == data.size ? (data.size * 1.2) : (data.bytesize * 0.8) ) if data.present?
          when "Date"
            worksheet.write(row,col,data.strftime("%Y/%m/%d"),@@myformat[:c])
            data_size = 10 if data.present?
          when "Time"
            worksheet.write(row,col,data.strftime("%Y/%m/%d %H:%M"),@@myformat[:c])
            data_size = 19 if data.present?
          when "Array"
            worksheet.write(row,col,data.join("\r\n"),@@myformat[:a])
            data_size = data.sort_by(&:length).last.size * 1.2 if data.present?
          else
#            p "#{data} is #{data.class.name}"
            worksheet.write(row,col,data,@@myformat[:c])
          end
          col_ws[col] = data_size if col_ws[col].blank? || col_ws[col] < data_size
        }unless datas.blank?
      end
    }unless array_data.blank?
    col_ws.each_with_index{|w,wi| worksheet.set_column(wi,wi,w) }unless col_ws.blank?
    row = 0
  end
  #
  #ホテル概要一覧
  def mk_list(evt,inventories)
    #一覧

    [1,32,20].each_with_index{|w,wi| worksheet.set_column(wi,wi,w) }
    sdc = inventories[:stay_dates].size
    row = 0
    worksheet.set_row(row, 22)
    worksheet.merge_range(row,1,row,2+sdc,"#{evt[:name]}_ホテル在庫一覧",@@myformat[:t])
    
    row += 2
    inventories[:stay_dates].each_with_index{|stay_daty,index|
      worksheet.write(row,3+index,stay_daty.strftime("%m/%d"),@@myformat[:tt_c])
    }
    worksheet.set_column(3,2+sdc,10)
    worksheet.set_column(3+sdc,3+sdc,1)
    #表題
    worksheet.merge_range(row-1,1,row,1,"ホテル",@@myformat[:tt_c2])
    worksheet.merge_range(row-1,2,row,2,"部屋",@@myformat[:tt_c2])
    if sdc > 1
      worksheet.merge_range(row-1,3,row-1,2+sdc,"宿泊日",@@myformat[:tt_c2])
    else
      worksheet.write(row-1,3,"宿泊日",@@myformat[:tt_c])
    end
    #印刷タイトル行設定
    worksheet.repeat_rows(0,row)
    row += 1
    #枠を固定
    worksheet.freeze_panes(row,3)
    inventories[:inventories].each{|hotel_id,evt_hotel|
      evt_hotel[:rooms].each_with_index{|room_data,index|
        if index == 0
          if evt_hotel[:rooms].size > 1
            worksheet.merge_range(row,1,row+evt_hotel[:rooms].size-1,1,evt_hotel[:hotel_name],@@myformat[:td_l2])
          else
            worksheet.write(row,1,evt_hotel[:hotel_name],@@myformat[:td_l])
          end
        end
        worksheet.write(row,2,room_data[1],@@myformat[:td_l])
        inventories[:stay_dates].each_with_index{|stay_daty,index|
          vhtml = "---"
          if evt_hotel[:inventories].has_key?(stay_daty)
            if evt_hotel[:inventories][stay_daty].has_key?(room_data[0])
              data = evt_hotel[:inventories][stay_daty][room_data[0]]
              vhtml = "#{data[:ticketing_count]}/#{data[:ticketing_limit]}"
            end
          end
          worksheet.write(row,3+index,vhtml,@@myformat[:td_c])
        }
        row += 1
      }
    } unless inventories.blank?
  end
  #
  #ホテル明細一覧
  def mkinfo(evt,evt_hotel,guest)
    sheet_name = evt_hotel[:hotel_name]
    sheet_name = sheet_name[0..5] if sheet_name.length > 10
    sheet_name = get_sheet_name(sheet_name)
    worksheet = @workbook.add_worksheet(sheet_name)
    worksheet.set_paper(9)      #A4サイズ
    worksheet.set_landscape()   #横向き
    worksheet.hide_gridlines()  #余分な罫線の印刷をさせない
    worksheet.set_margins(0.2)  #余白を設定
    [1,20,12,10,15,15,7,2,20,1].each_with_index{|w,wi| worksheet.set_column(wi,wi,w) }
    row = 0
    worksheet.set_row(row, 22)
    worksheet.merge_range(row,1,row,8,"#{evt_hotel[:hotel_name]}_宿泊者一覧",@@myformat[:t])
    row += 1
    worksheet.write(row,1,evt.app_cd_title,@@myformat[:tt_c])
    worksheet.write(row,2,"状況",@@myformat[:tt_c])
    worksheet.write(row,3,"宿泊日",@@myformat[:tt_c])
    worksheet.write(row,4,"部屋",@@myformat[:tt_c])
    worksheet.write(row,5,"食事等",@@myformat[:tt_c])
    worksheet.write(row,6,"数量",@@myformat[:tt_c])
    worksheet.merge_range(row,7,row,8,"利用者",@@myformat[:tt_c2])
    #印刷タイトル行設定
    worksheet.repeat_rows(0,row)
    row += 1
    #枠を固定
    worksheet.freeze_panes(row,0)
    guest.each{|app_id,app_data|
      app_data[:guest_data].each_with_index{|guest_data,gd_index|
        guest_data[:guests].each_with_index{|guests,gs_index|
          guests[1].each_with_index{|guest,g_index|    
            if g_index==0
              if gs_index==0
                if gd_index == 0
                  if app_data[:guest_count] > 1
                    worksheet.merge_range(row,1,row+app_data[:guest_count]-1,1,app_data[:app_cd],@@myformat[:td_l2])
                    worksheet.merge_range(row,2,row+app_data[:guest_count]-1,2,list2str(App::APP_STS,app_data[:app_sts]),@@myformat[:td_l2])
                  else
                    worksheet.write(row,1,app_data[:app_cd],@@myformat[:td_l])
                    worksheet.write(row,2,list2str(App::APP_STS,app_data[:app_sts]),@@myformat[:td_l])
                  end
                end
                gc = guest_data[:guest_count]
                if gc > 1
                  worksheet.merge_range(row,3,row+gc-1,3,"#{guest_data[:stay_date].strftime("%m/%d")}",@@myformat[:td_c2])
                  worksheet.merge_range(row,4,row+gc-1,4,"#{guest_data[:room]}",@@myformat[:td_l2])
                  worksheet.merge_range(row,5,row+gc-1,5,"#{guest_data[:meal_type]}",@@myformat[:td_l2])
                  worksheet.merge_range(row,6,row+gc-1,6,"#{guest_data[:order_count]}室",@@myformat[:td_r2])
                else
                  worksheet.write(row,3,"#{guest_data[:stay_date].strftime("%m/%d")}",@@myformat[:td_c])
                  worksheet.write(row,4,"#{guest_data[:room]}",@@myformat[:td_l])
                  worksheet.write(row,5,"#{guest_data[:meal_type]}",@@myformat[:td_l])
                  worksheet.write(row,6,"#{guest_data[:order_count]}室",@@myformat[:td_r])
                end
              end
              if guests[1].size > 1
                worksheet.merge_range(row,7,row+guests[1].size-1,7,"#{guests[0]}",@@myformat[:td_r2])
              else
                worksheet.write(row,7,"#{guests[0]}",@@myformat[:td_r])
              end
            end
            worksheet.write(row,8,guest,@@myformat[:td_l])
            row += 1
          } unless guests.blank?
        } unless guest_data[:guests].blank?
      } unless app_data[:guest_data].blank?
    }unless guest.blank?
  end
end
