#= 昼食集計帳票エクセル作成クラス
class Manager::LunchSummaryController < Manager::HomeController
  before_action :set_my_global_variable
  before_action :set_target

  # 昼食集計画面表示
  def index
    @title="昼食集計"
    @today = Date.today
    @grid_setting = {
      column_size: (@t_tarm[:length][:begin_date]..@t_tarm[:length][:end_date]).count + 4 + 1
    }
  end

  # 昼食集計エクセルを作成、送信
  def excel_output
    whs = WhSummary.find_by_tdate(@s_date)
    y = whs.t_year
    m = whs.t_month;
    export_file_name = "昼食集計(#{y}年#{m}月度)"
    excel = Excel::LunchSummaryExcelClass.new(export_file_name)
    workbook = excel.excel

    #== エクセル書式設定
    col_width = 4.5
    title_format =  excel.get_format(fweight:true,fsize:14)
    text_format_align_r =  excel.get_format(align:'right')
    header_format =  excel.get_format(bgcolor:'cyan',align:'center',border:true)
    branch_format =  excel.get_format(bgcolor:'gray',align:'center',border:true)
    branch_format_total =  excel.get_format(bgcolor:'gray',align:'center',border:[5,5,5,5])
    branch_format_total_l =  excel.get_format(bgcolor:'gray',align:'center',border:[5,1,5,5])
    branch_format_total_c =  excel.get_format(bgcolor:'gray',align:'center',border:[5,1,5,1])
    branch_format_total_r =  excel.get_format(bgcolor:'gray',align:'center',border:[5,5,5,1])
    name_format =  excel.get_format(bgcolor:'silver',align:'center',border:true)
    body_format =  excel.get_format(bgcolor:'white',align:'center',border:true)
    body_format_total =  excel.get_format(bgcolor:'white',align:'center',border:[5,5,5,5])
    body_format_total_l =  excel.get_format(bgcolor:'white',align:'center',border:[5,1,5,5])
    body_format_total_c =  excel.get_format(bgcolor:'white',align:'center',border:[5,1,5,1])
    body_format_total_r =  excel.get_format(bgcolor:'white',align:'center',border:[5,5,5,1])
    body_format_red =  excel.get_format(bgcolor:'white',align:'center',border:true,fcolor:'red')
    
    #==

    @datas.each do |branch_cd,users|
      t_branch = @branches.find{|b| b[0]==branch_cd}
      title = "#{y}年#{m}月度(#{@s_date.strftime("%Y/%m/%d")}～#{@e_date.strftime("%Y/%m/%d")})"
      sheet_data = {name:nil,data:nil}
      sheet_data[:name] = t_branch[1]

      #== table_data: 2次元配列
      #== セル情報は配列使用 ["値", "書式設定format型"]
      table_data = []
      table_data << [[title,title_format]]
      table_data << []

      tmp_line = []
      tmp_line << [t_branch[1],branch_format]
      (@s_date..@e_date).each do |day|
        tmp_line << [day.day,header_format]
      end
      # メニューごとの集計カラム
      %w[福(み有 福(み無 土(み無 弁(幕 弁(から 祝(幕 す(牛].each do |d|
        tmp_line << [d,branch_format]
      end
      tmp_line << ["合計",branch_format]
      table_data << tmp_line
      
      users.each do |user_id,data|
        tmp_line = []
        tmp_line << [data[:user_info][:name],name_format]
        data[:cal_cell].each do |d|
          format = d[0]=="み無" ? body_format_red : body_format
          tmp_line << [d[0],format]
        end
        @menu_index.each do |id|
          tmp_line << [data[:order_total][id],name_format]
        end
        tmp_line << [data[:order_total_sum],name_format]
        table_data << tmp_line
      end

      # 日付毎集計
      temp_line = []
      temp_line << ["合計",branch_format_total_l]
      (@s_date..@e_date).each do |day|
        total = 0
        if @order_sum[:daily_orders][t_branch[0]].present?
          total = @order_sum[:daily_orders][t_branch[0]][day]&.values&.sum.to_i
        end
        temp_line << [total,body_format_total_c]
      end
      @menu_index.each do |id|
        total = 0
        if @order_sum[:monthly_orders][t_branch[0]].present?
          total = @order_sum[:monthly_orders][t_branch[0]][id].to_i
        end
        temp_line << [total,branch_format_total_c]
      end

      temp_line << [@order_sum[:monthly_orders][t_branch[0]].present? ? @order_sum[:monthly_orders][t_branch[0]].values.sum : 0 ,branch_format_total_r]
      table_data << temp_line

      # 福祉センターの注文数
      temp_line = []
      total = @order_sum.dig(:fukushi_center_orders,t_branch[0]).to_i
      (@s_date..@e_date).to_a.size.times {|n| temp_line << []}
      temp_line << ["福祉センター分合計",text_format_align_r]
      table_data << temp_line

      sheet_data[:data] = table_data
      #==


      worksheet = workbook.add_worksheet(sheet_data[:name])
      worksheet.set_column(0, 0, 14)
      worksheet.set_column(1, (@s_date..@e_date).count, col_width)
      worksheet.set_column((@s_date..@e_date).count, (@s_date..@e_date).count+8, 7)
      total_row = 2+1+users.size
      worksheet.set_row(total_row,24)
      worksheet.set_row(total_row+1,24)
      worksheet.merge_range(total_row+1,1+(@s_date..@e_date).count,total_row+1,1+(@s_date..@e_date).count+2,total.to_s,body_format_total)
      setdata(worksheet,sheet_data[:data])
    end
    excel_path = excel.fin()
    send_file(excel_path,:filename=>"#{export_file_name}.xls",:status=>200) 
  
  end

  private
  def setdata(worksheet,data,offset=[0,0])
    x_offset = 0 + offset[0]
    y_offset = 0 + offset[1]
    data.each_with_index do |dr,row_index|
      dr.each_with_index do |cel_data,col_index|
        worksheet.write(row_index + y_offset, col_index + x_offset, cel_data[0], cel_data[1])
      end
    end
  end
  def set_my_global_variable
    @my_setting = {:table=>LunchMenu,
      :def_where=>[],
      :back_links => [{:txt=>I18n.t("btn_labels.link_to",:to=>I18n.t("page_titles.menu")),
          :path=>{:controller=>:home ,:action => :menu} }],
      :multipart_flg=>false,
      }
  end

  def set_target()
    @s_date,@e_date = params.values_at(:s_date,:e_date).map{|date_str| Date.parse(date_str)}
    @branches = Branche.cargo_work_group.pluck(:cd,:name,:color)
    @menu_snames = LunchMenu.all.pluck(:id,:s_name).to_h
    @vendor_names = LunchVendor.all.pluck(:id,:name).to_h
    @menu_index = LunchMenu.all.order(:desp_index).ids
    def_order_total = @menu_snames.transform_values{|v| 0 }
    applicable = Applicable.get_applicable(2,@s_date)
    @wokers = Woker.includes(:user).where(:applicable=>applicable,:branch_cd=>@branches.map{|b| b[0]}).order(:branch_cd,:desp_index)
    @lunch_orders = LunchOrder.where(:order_date=>(@s_date..@e_date)).where.not(:lunch_menu_id=>[0,-1]).order(:branche_cd,:user_id)
    def_cells = Array.new((@s_date..@e_date).count,"")
    @datas = {}
    @order_sum = {
      daily_orders: {}, # keyは日付,valueはハッシュ(keyはメニューID,valueは注文数)
      monthly_orders: {} # keyは日付,valueはハッシュ(keyはメニューID,valueは注文数)
    }


    fukushi_center_menus = LunchMenu.where(:lunch_vendor_id=>LunchVendor.where("name like ?","福祉%").ids).ids

    @wokers.each do |woker|
      w_brcd = woker[:branch_cd]
      w_cd = woker[:login_id]
      user = woker.user
      next if user.nil?
      order_total = def_order_total.dup
      @datas[w_brcd] ||= {}
      @datas[w_brcd][w_cd] ||= {:user_info=>nil,:order_hist=>[],:cal_cell=>nil}
      @datas[w_brcd][w_cd][:user_info] ||= woker.user  
      @datas[w_brcd][w_cd][:cal_cell] ||= [*def_cells]  
      
      my_orders = @lunch_orders.select{|order| order.user_id == woker.user.id}
      @datas[w_brcd][w_cd][:order_hist] << my_orders
      my_orders.each do |order|
        cell_offset = (order.order_date - @s_date).to_i
        @datas[w_brcd][w_cd][:cal_cell][cell_offset] = [@menu_snames[order[:lunch_menu_id]],order[:id]]


        order_total[order[:lunch_menu_id]] +=1
        @order_sum[:daily_orders][w_brcd] ||= {}
        @order_sum[:daily_orders][w_brcd][order.order_date] ||= def_order_total.dup
        @order_sum[:daily_orders][w_brcd][order.order_date][order[:lunch_menu_id]] += 1
        @order_sum[:monthly_orders][w_brcd] ||= def_order_total.dup
        @order_sum[:monthly_orders][w_brcd][order[:lunch_menu_id]]+= 1

        # 福祉センターの注文数を集計
        if fukushi_center_menus.include?(order[:lunch_menu_id])
          @order_sum[:fukushi_center_orders] ||= {}
          @order_sum[:fukushi_center_orders][w_brcd] ||= 0
          @order_sum[:fukushi_center_orders][w_brcd] += 1
        end
      end
      @datas[w_brcd][w_cd][:order_total] ||= order_total
      @datas[w_brcd][w_cd][:order_total_sum] = order_total.values.sum
    end

  end



end
