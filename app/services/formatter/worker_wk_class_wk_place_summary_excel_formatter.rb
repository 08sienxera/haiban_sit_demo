class Formatter::WorkerWkClassWkPlaceSummaryExcelFormatter < Formatter::Formatter
  CellInfo = Struct.new(:value,:bg_color,:f_color)

  def initialize(wh,branche,wokers,result_cargo_workers,cargo_workers,result_cargo_machines,cargo_machines)
    @wh = wh
    @branche = branche
    @wokers = wokers.to_a
    @result_cargo_workers = result_cargo_workers.to_a
    @cargo_workers = cargo_workers.to_a
    @result_cargo_machines = result_cargo_machines.to_a
    @cargo_machines = cargo_machines.to_a
    @unique_names = generate_unique_name(wokers)
    super()
    convert()
  end

  def convert()
    data = {
      :t_date=>@t_date,
      :file_name=>"",
      :sheet_count=>0,
      :sheets=>[],
    }


    converted_hash = {}
    @wokers.filter{|woker| woker.branch_cd==@branche.cd}.each do |woker|
      user = woker.user
      converted_hash[user.login_id] = []

      # -- まとめられる
      @result_cargo_workers.select{|rcw| rcw.login_id==user.login_id}.each do |rcw|
        rcms = find_my_machine(rcw,@result_cargo_machines)
        datas = Converter::WorkerWkClassWkPlaceSummaryConverter.new(woker,rcw,rcms).call()
        converted_hash[user.login_id] += datas
      end
      @cargo_workers.select{|cw| cw.login_id==user.login_id}.each do |cw|
        cms = find_my_machine(cw,@cargo_machines)
        datas = Converter::WorkerWkClassWkPlaceSummaryConverter.new(woker,cw,cms).call()
        converted_hash[user.login_id] += datas
      end
      # --
    end

    wk_class_wk_place_hash = {}
    converted_hash.each do |login_id,conveted_datas|
      next if conveted_datas.blank?
      conveted_datas.each do |data|
        wk_class,wk_place,text,bg_color,f_color = data.values_at(:wk_class,:wk_place,:text,:bg_color,:f_color)
        wk_class_wk_place_hash[wk_place] ||= {}
        wk_class_wk_place_hash[wk_place][login_id] ||= {}
        wk_class_wk_place_hash[wk_place][login_id][wk_class] ||= 0 #(仮 : 最終は日付
        wk_class_wk_place_hash[wk_place][login_id][wk_class] += 1
      end
    end

    store_data(wk_class_wk_place_hash)
    return

    # --
    sheet = sheet_template()
    sheet[:sheet_name] = branch.name
    sheet[:sheet_title] = branch.name
    @wokers.filter{|woker| woker.branch_cd==branch.cd}.each do |woker|
      row = []
      row << [get_unique_name(woker),"",""]
        (@wh.s_date..@wh.e_date).each do |wk_date|
          row << get_data(
            woker,
            wk_date,
            wk_date >= Date.today ? @cargo_workers : @result_cargo_workers,
            wk_date >= Date.today ? @cargo_machines : @result_cargo_machines,
            @vacations
            )
          end
          sheet[:sheet_data] << row
        end
        data[:sheets] << sheet
        
    # --
    data[:sheet_count] = data[:sheets].size
    store_data(data)
  end

  private   

  def max_zip(list)
    ret = []
    loop_num = list.map(&:size).max
    loop_num.times do |i|
      ret << list.map{|l| l[i]}
    end
    ret
  end
  def sheet_template
    return {
      :sheet_name  => "",
      :sheet_title => "",
      :sheet_data  => [],
    }
  end
  def empty_data
    return ["","",""] # 値、文字色、背景色
  end


  # --private
  def generate_unique_name(wokers)
    ret = wokers.group_by{|w| w.user.name}.select{|_,arr| arr.size>1}
    ret if ret.blank?
    ret = ret.transform_values {|wokers|
      wokers.map.with_index do |w,i|
        suf = ("A".ord+i).chr
        [w.login_id,w.user.name+suf]
      end
    }
    ret
  end

  def get_unique_name(worker)
    return @unique_names[worker.user.name].blank? ? worker.user.name : @unique_names[worker.user.name].find{|login_id,_| login_id==worker.login_id}[1]
  end

  def find_my_machine(work,machine_sources)
    my_machine = [nil,nil] # 主、副
    parent_key = work.class==ResultCargoWorker ? :result_cargo_id : :cargo_id
    machines = machine_sources.select{|cm| cm[parent_key]==work.assigned_cargo.id}
    if machines
      my_machine[0] = machines.find{|cm| cm.wk_type==work.wk_type && cm.wk_index==work.wk_index}
      my_machine[1] = machines.find{|cm| cm.wk_type==work.wk_type && cm.wk_index==work.wk_index.to_i-1}
    end
    my_machine
  end

end
