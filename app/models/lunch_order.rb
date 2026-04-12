class LunchOrder < ApplicationRecord
  extend Common::Func
  default_scope {where(:deleted_at => nil)}
  validates :lunch_location_id, presence: {message: "を選択してください"}
  validates :lunch_menu_id, presence: { message: "を選択してください" }
  belongs_to :user
  
  OrderBranchGroup = {"10"=>["1","2"],"20"=>["3","4"]}

  # 対象日切替時刻
  SwitchHour = 16 

  #===表示対象日取得（SwitchHour時以降は翌日、以前は当日
  def self.get_today
    today = Date.today
    if Time.now.hour < SwitchHour
      return today
    else
      return (today+1)
    end
  end

  #===注文実績の取得
  # 引数 : ユーザId(user_id),集計開始日,集計終了日
  # 戻値 : 集計範囲内でuser_idが注文した合計数
  def self.get_orders(user_id,begin_date,end_date)
    orders = LunchOrder.where(:user_id=>user_id).where(["order_date between ? and ? ",begin_date,end_date])
    orders
  end

  #
  #===昼食集計
  def self.calc_total(t_date,branche_cd=nil)
    ret = {}
    #注文日、注文先データ、メニューリスト
    wh = WhCalendar.find_by_t_date(t_date)
    ret[:day_info] = wh
    if wh.present?
      ret[:vendor] = wh.lunch_vendor
      #メニューリスト
      ret[:menu] = LunchMenu.getdatalist({:order=>:desp_index,:where=>{:lunch_vendor_id=>wh[:lunch_vendor_id]}})
    end
    #配送先リスト
    locations = LunchLocation.all.select("id,concat(s_name,'(',name,')') p_name").order(:desp_index)
    ret[:locations] = LunchLocation.getdatalist({:text=>:p_name,:datas=>locations}) + [["不要","-1"],["未注文","0"]]
    #グループリスト
    ret[:branches] = Branche.get_sum_list(t_date)
    #ロックチェック
    ret[:lock] = LunchOrderLock.ck_lock_all(t_date)
    #集計初期化
    order_count = {-1=>{:users=>[],:order_num=>0}}
    ret[:menu].each{|txt,lunch_menu_id|
      order_count[lunch_menu_id.to_i] = {:users=>[],:order_num=>0}
    }unless ret[:menu].blank?
    locations = {}
    ret[:locations].each{|txt,lunch_location_id|
      locations[lunch_location_id.to_i] = Marshal.load(Marshal.dump(order_count))
    }unless ret[:locations].blank?
    orders = {:total=>Marshal.load(Marshal.dump(locations)),nil=>Marshal.load(Marshal.dump(locations))}
    ret[:branches].each{|branche_nm,branche_cd|
      orders[branche_cd] = Marshal.load(Marshal.dump(locations))
    }unless ret[:branches].blank?


    applied = []
    where = {:order_date=>t_date}
    where[:branche_cd]=branche_cd if branche_cd.present?

    all_wokers = Woker.get_latest(t_date).joins(:user).select("wokers.*,users.id as user_id,users.name as user_name").order("wokers.branch_cd asc, wokers.desp_index asc, users.name asc")
    data_tbl = self.joins("LEFT JOIN lunch_menus ON lunch_orders.lunch_menu_id = lunch_menus.id").where(where).order("lunch_menus.desp_index asc").group_by(&:lunch_menu_id)
    #課集計先
    #注文場所毎に合計数と対象ユーザを追加
    data_tbl.each{|menu_id,lunch_orders|
      all_wokers.each do |woker|
        # -- Worker info
        user_id = woker.user_id
        user_name = woker.user_name
        # -- Order info
        order = lunch_orders.find{|o| o.user_id==user_id}
        next if order.blank?
        location = order[:lunch_location_id]
        menu = order[:lunch_menu_id]
  
        next if orders.dig(:total,location,menu).blank?
        applied << user_id
  
        orders[:total][location][menu][:order_num] += order[:order_num]
        orders[:total][location][menu][:users] << [user_name,user_id]
        if orders.has_key?(order[:branche_cd])
          b = order[:branche_cd]
          orders[b][location][menu][:order_num] += order[:order_num]
          orders[b][location][menu][:users] << [user_name,user_id]
          sum_key = Branche::WorkerBranchSumKey[b]
          orders[sum_key][location][menu][:order_num] += order[:order_num]
          orders[sum_key][location][menu][:users] << [user_name,user_id]
        end
      end
    } if data_tbl.present?

    #休暇申請データを取得
    vt_map = VacationType.all.pluck(:base_no,:time_sheet_name).to_h
    vacation_data = Vacation.where(:vacation_day=>t_date).index_by(&:user_id)

    #未申し込みユーザの取得
    unapp_wokers = Woker.get_latest(t_date).where(:branch_cd=>%w(1 2 3 4)).joins(:user).select("wokers.*,users.id as user_id,users.name as user_name")
    unapp_wokers = unapp_wokers.where.not("users.id in (?)",applied) if applied.present?
    unapp_wokers = unapp_wokers.order("wokers.branch_cd asc, wokers.desp_index asc, users.name asc")
    cws_on_tdate = CargoWorker.where(:work_date=>t_date)
    unapp_wokers.each{|w|
      user_name = w.user_name
      woker_branch = w.branch_cd
      vacation = vacation_data[w.user_id] 
      onwork = true #出勤有無
      if vacation.present?
        # 全休の者は非表示、半休の者は表示
        vac_str = vt_map[vacation.base_no]
        vac_str += vacation.at_work_str if vacation.base_no==6
        vac_str = "(#{vac_str})"
        user_name += vac_str
        onwork = false unless vacation.works_on?
        onwork = cws_on_tdate.pluck(:login_id).include?(w.login_id) unless onwork # 配番作業員に設定されている場合
      end
      orders[:total][0][-1][:users]  << [user_name,w.user_id,onwork]
      if orders.has_key?(woker_branch)
        orders[woker_branch][0][-1][:users]  << [user_name,w.user_id,onwork]
        sum_key = Branche::WorkerBranchSumKey[woker_branch]
        orders[sum_key][0][-1][:users] << [user_name,w.user_id,onwork]
      end
    }
    ret[:orders] = orders
    return ret

  end

  #===昼食注文を取得
  # 引数
  #   user:User 対象ユーザ
  #   t_date:Date 対象日
  #   require_new_lunchorder_if_not_found:boolean 昼食注文が存在しない場合の挙動を制御
  #     true=>初期値をセットしたnew LunchOrderを返却
  #     false=>nilを返却
  #
  def self.get_lunch_order(user,t_date=Date::today,require_new_lunchorder_if_not_found=false)
    # user がUserクラスでない場合、エラーをスローする
    raise ArgumentError, "Invalid user" unless user.is_a?(User)
    order = LunchOrder.find_by(:order_date=>t_date,:user_id=>user.id) || LunchOrder.new

    # orderがあれば返却し終了
    return order unless order.new_record?
    # 初期設定したorderが不要の場合nil返却し終了
    return nil unless require_new_lunchorder_if_not_found

    # 初期設定したlunch_orderを返す
    wh = WhCalendar.find_by_t_date(t_date)

    order[:order_date] = t_date
    order[:user_id] = user.id
    order[:branche_cd] = Woker.get_user_branch(user.login_id,t_date)[:branch_cd]
    order[:lunch_location_id] = nil
    order[:lunch_vendor_id] = wh[:lunch_vendor_id]
    order[:created_uid] = user.login_id
    order[:updated_uid] = user.login_id

    # 休暇登録があれば
    # vacation = Vacation.find_by(:user_id=>user.id,:vacation_day=>t_date)
    vacation = Vacation.find_by(:user_id=>user.id,:vacation_day=>t_date)
    if vacation
      no_lunch_required_hour = 12 # 昼食不要の境界時刻
      on_work = vacation.works_on?
      require_lunch = nil
      if on_work
        order[:lunch_location_id] = -1 if vacation.leav_time.present? && vacation.leav_time[..1].to_i <= no_lunch_required_hour
      else
        order[:lunch_location_id] = -1
      end
    elsif wh.wh_flg == 1
      order[:lunch_location_id] = -1
    else
      order[:lunch_location_id] = nil
    end
    order
  end
  #
  #===テスト用昼食注文登録
  def self.mk_test_order(tdates)
    ret = []
    #乱数初期化
    random = Random.new()
    #期間
    term =[tdates[:length][:begin_date]..tdates[:length][:end_date]]
    #配送先リスト
    locations = LunchLocation.all.select(:id).map{|ll| ll[:id]}
    locations << "0"
    #メニューリスト
    lunch_menus = {}
    LunchMenu.all.each{|lm|
      lunch_menus[lm[:lunch_vendor_id]] ||= []
      lunch_menus[lm[:lunch_vendor_id]] << lm[:id]
    }
    
    #カレンダー
    wh_list = WhCalendar.find_by_term(tdates[:length][:begin_date],tdates[:length][:end_date])
    #ユーザリスト
    wokers = [] ; woker_branche = {}
    Woker.select(:login_id,:branch_cd).where(:applicable=>Applicable.get_applicable(2,tdates[:length][:begin_date]),:branch_cd=>Branche::WorkerBranchCd).each{|woker|
      wokers << woker[:login_id]
      woker_branche[woker[:login_id]] = woker[:branch_cd]
    }
    #従業員No->ユーザIDのリスト
    userid_list = [] ; user_branche = {}
    User.where(:login_id=>wokers).each{|user|
      userid_list << user[:id]
      user_branche[user[:id]] = woker_branche[user[:login_id]]
    }
    user_num = userid_list.size.to_f
    #休暇申請データ
    vacation_data = {}
    vacations = Vacation.where({:vacation_day=>term})
    vacations.each{|vacation|
      vacation_data[vacation[:vacation_day]] ||= {}
      vacation_data[vacation[:vacation_day]][vacation[:user_id]] = vacation
    }unless vacations.blank?
    #注文済みデータ
    order_data = {}
    orders = self.where({:order_date=>term})
    orders.each{|order|
      order_data[order[:order_date]] ||= []
      order_data[order[:order_date]] << order[:user_id]
    }unless orders.blank?
    #期間中の注文を登録
    wh_list.each{|wk_date,wh_data|
      vacation_data[wk_date] = {} if vacation_data[wk_date].blank?
      order_data[wk_date] = {} if order_data[wk_date].blank?
      lunch_menu = lunch_menus[wh_data[:lunch_vendor_id]]
      
      if wh_data[:wh_flg] == 0
        l_wokers = Marshal.load(Marshal.dump(userid_list))
        #休暇者を除外
        vacation_data[wk_date].each{|user_id,vd|
          l_wokers.delete(user_id) if vd[:base_no]!=1 && vd[:base_no]!=2
        }unless vacation_data.blank?
      else
        l_wokers = []
        #休日出勤者のみ
        vacation_data[wk_date].each{|user_id,vd|
          l_wokers << user_id if vd[:base_no]==1
        }unless vacation_data.blank?
      end
      #注文済みユーザを除外
      order_data[wk_date].each{|user_id|
        l_wokers.delete(user_id)
      }unless order_data[wk_date].blank?
      #20%
      while l_wokers.size> 0 && (l_wokers.size / user_num) > 0.2
        t_woker =  l_wokers[random.rand(l_wokers.size)]

        order = {
          :order_date=>wk_date,
          :user_id=>t_woker,
          :branche_cd=>user_branche[t_woker],
          :lunch_location_id=>locations[random.rand(locations.size)],
          :lunch_vendor_id=>wh_data[:lunch_vendor_id],
          :lunch_menu_id=>lunch_menu[random.rand(lunch_menu.size)],
          :order_num=>1,
          :created_uid=>"test",
          :updated_uid=>"test",
        }
        self.create(order)
        l_wokers.delete(t_woker)
      end 
      wk_date += 1
    }unless wh_list.blank?
    return ret
  end
end
