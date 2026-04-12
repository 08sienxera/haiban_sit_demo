class Vacation < ApplicationRecord
  belongs_to :user
  belongs_to :vacation_type

  extend Common::Func
  default_scope {where(:deleted_at => nil)}


  # 状態リスト
  Sts = [["未承認","0"],["承認済","1"],["差戻","2"]]
  # 連続勤務アラート日数
  OverWorkLimit = 13
  # 公休取得不可日リスト
  BaseNo6NgList = ["08-13","08-16","12-29","01-04"]
  # 遅出　出勤希望時刻　leav_timeに登録
  ReachTimeList = ["","07:30","08:00"]
  # 早退　退勤希望時刻　leav_timeに登録
  LeavTimeList = ["","16:00", "16:30", "17:00", "17:30", "18:00", "18:30", "19:00", "19:30", "20:00", "20:30", "21:00", "21:30", "22:00", "22:30", "23:00", "23:30"]

  FullNameList = [["午前看護","31"],["午後看護","32"],["午前介護","33"],["午後介護","34"],["午前年休","41"],["午後年休","42"]]
  #
  #===入力画面フォームの生成
  def self.set_input_form(key)
    form = Common::CommonClass.new(key)
    form.setparams("vacation_day",{"title"=>self.human_attribute_name(:vacation_day),"type"=>"textD",'size'=>"11","maxlength"=>"10","inputFlg"=>1,"essFlg"=>1,"align"=>"L"})
    vacation_list = VacationType.getdatalist({:key=>:base_no,:text=>:time_sheet_name,:order=>:base_no,:where=>"base_no <> 1 and base_no > 3 and base_no<=30"})
    vacation_list += Vacation::FullNameList
    form.setparams("base_no",{"title"=>self.human_attribute_name(:vacation_type_id),"type"=>"radio",'size'=>"2","maxlength"=>"2","inputFlg"=>1,"essFlg"=>0,"align"=>"C",
      "list"=>vacation_list,"onclick"=>"setVacationTypeBaseNo(this)","list_row_num"=>6})
    form.setparams("at_work",{"title"=>self.human_attribute_name(:at_work),"type"=>"radio",'size'=>"2","maxlength"=>"2","inputFlg"=>1,"essFlg"=>0,"align"=>"C",
      "list"=>KAFUKA_MARK})
    form.setparams("origin_date",{"title"=>"振替元日","type"=>"textD",'size'=>"11","maxlength"=>"10","inputFlg"=>1,"essFlg"=>0,"align"=>"L"})
    form.setparams("origin_date2",{"title"=>"休日出勤日","type"=>"textD",'size'=>"11","maxlength"=>"10","inputFlg"=>1,"essFlg"=>0,"align"=>"L"})
    form.setparams("arriv_time",{"title"=>self.human_attribute_name(:arriv_time),
      "type"=>"select",'size'=>"6","maxlength"=>"5","inputFlg"=>1,"essFlg"=>0,"align"=>"L","list"=>ReachTimeList})
    form.setparams("leav_time",{"title"=>self.human_attribute_name(:leav_time),
      "type"=>"select",'size'=>"6","maxlength"=>"5","inputFlg"=>1,"essFlg"=>0,"align"=>"L","list"=>LeavTimeList})
    form.setparams("vacation_end_day",{"title"=>"終了日","type"=>"textD",'size'=>"11","maxlength"=>"10","inputFlg"=>1,"essFlg"=>0,"align"=>"L","bwd"=>"長期間登録の場合に入力してください。"})
    return form
  end

  #
  #===一覧画面フォームの生成
  def self.set_list_form(key)
    form = Common::CommonClass.new(key)
    vacation_list = VacationType.getdatalist({:key=>:base_no,:text=>:time_sheet_name,:order=>:base_no})
    branch_list = Branche.getdatalist({:key=>:cd,:text=>:name,:where=>{:applicable=>Applicable.get_applicable(1)},:order=>:desp_index})
    form.setparams('id',{'title'=>'ID','type'=>'hidden','size'=>'20','maxlength'=>'16','inputFlg'=>0,'essFlg'=>0,'align'=>'R','noserch'=>"1"})
    form.setparams("login_id",{"title"=>self.human_attribute_name(:login_id),"type"=>"textA",'size'=>"20","maxlength"=>"16","inputFlg"=>0,"essFlg"=>0,"align"=>"L"})
    form.setparams("name",{"title"=>User.human_attribute_name(:name),"type"=>"textJ",'size'=>"32","maxlength"=>"32","inputFlg"=>0,"essFlg"=>0,"align"=>"L"})
    form.setparams("branch_cd",{"title"=>self.human_attribute_name(:branch_cd),"type"=>"select",'size'=>"9","maxlength"=>"8","inputFlg"=>0,"essFlg"=>0,"align"=>"L","list"=>branch_list})
    form.setparams("vacation_day",{"title"=>self.human_attribute_name(:vacation_day),"type"=>"textD",'size'=>"11","maxlength"=>"10","inputFlg"=>0,"essFlg"=>0,"align"=>"L","list"=>branch_list})
    form.setparams("base_no",{"title"=>self.human_attribute_name(:vacation_type_id),"type"=>"select",'size'=>"2","maxlength"=>"2","inputFlg"=>0,"essFlg"=>0,"align"=>"C",
      "list"=>vacation_list,"list_row_num"=>6})
    form.setparams("at_work",{"title"=>self.human_attribute_name(:at_work),"type"=>"select",'size'=>"2","maxlength"=>"2","inputFlg"=>0,"essFlg"=>0,"align"=>"C",
      "list"=>KAFUKA_MARK})
    form.setparams("origin_date",{"title"=>"振替日","type"=>"textD",'size'=>"11","maxlength"=>"10","inputFlg"=>0,"essFlg"=>0,"align"=>"L"})
    form.setparams("leav_time",{"title"=>self.human_attribute_name(:leav_time),"type"=>"textT",'size'=>"6","maxlength"=>"5","inputFlg"=>1,"essFlg"=>0,"align"=>"L"})
    form.setparams("sts",{"title"=>self.human_attribute_name(:sts),"type"=>"select",'size'=>"2","maxlength"=>"2","inputFlg"=>0,"essFlg"=>0,"align"=>"C",
      "list"=>Sts})
    return form
  end
  #
  #===休暇カレンダーデータ取得
  def self.load_calendar(s_date,e_date,branche_cd=nil,my_id=nil,t_date:nil)
    load_s_date = s_date-OverWorkLimit-1
    menbers = Woker.get_menber_list(t_date||s_date,branche_cd,my_id)
    calendar = {:wh=>WhCalendar.find_by_term(load_s_date,e_date),
      :branche=>Branche.get_assignment_list(t_date||s_date),
      :type_list=>VacationType.getdatalist({:key=>:id,:text=>:time_sheet_name,:type=>'hash'}),
      :menbers=>menbers,:vacations=>{},:counts=>{:total=>{:total=>0}},:member_count=>{:total=>0}}
    calendar[:branche].each{|branche_cd,branche_info|
      calendar[:counts][branche_cd]={:total=>0}
      calendar[:member_count][branche_cd]=0
    }
    vacations = self.where(:login_id=>menbers.map{|menber| menber["login_id"]},:vacation_day=>[load_s_date..e_date])
    vacations.each{|vacation|
      calendar[:vacations][vacation[:login_id]] ||= {}
      calendar[:vacations][vacation[:login_id]][vacation[:vacation_day]] = vacation
      
      work_on = vacation.works_on? || vacation.holiday_work?
      if !work_on && vacation[:branch_cd].present?
        calendar[:counts][:total][:total] += 1
        calendar[:counts][:total][vacation[:vacation_day]] ||= 0
        calendar[:counts][:total][vacation[:vacation_day]] += 1
        calendar[:counts][vacation[:branch_cd]][:total] += 1
        calendar[:counts][vacation[:branch_cd]][vacation[:vacation_day]] ||= 0
        calendar[:counts][vacation[:branch_cd]][vacation[:vacation_day]] += 1
      end
    }unless vacations.blank?
    return calendar
  end
  
  #
  #===公休日データ作成
  def self.create_vacation(indata)
    vacation = self.unscoped.find_by(:vacation_day=>indata[:vacation_day],:user_id=>indata[:user_id]) || self.new(indata)
    if vacation[:deleted_at].present?
      [:user_id,:branch_cd,:vacation_type_id,:at_work,:base_no,:updated_uid,:arriv_time,:leav_time,:origin_date,:vacation_id].each{|key| vacation[key] = indata[key]}
      vacation[:at_work] = nil if indata[:base_no]!=6
      vacation[:sts] = 0
      vacation[:deleted_at] = nil
    end
    vacation.auto_fill
    vacation.save!
    return vacation
  end

  def auto_fill()
    case self.base_no
    when 31,33,41 # AM leav_time追加
      self.arriv_time = '13:00' if self.arriv_time.blank?
    when 32,34,42 # PM leav_time追加
      self.leav_time = '12:00' if self.leav_time.blank?
    end
  end


  def remove_and_restore_origin_vacation()
    ret = {result:false, msg:"", data:{}}
    origin_vacation = self.restore_origin_vacation
    self.destroy
    ret[:result] = true
    ret[:data] = {
      :removed_vacation => self,
      :restored_vacation => origin_vacation
    }
    return ret
  end

  # base_no== 7(振休)  ⇒元休暇の復活 and self.vacation_idをnil更新
  # base_no==17(代休)  ⇒元休暇のstsを5->4に戻す and self.vacation_idをnil更新
  def restore_origin_vacation()
    result = nil
    return result if self.vacation_id.blank?

    case self.base_no
    when 7
      origin_vacation = Vacation.unscoped.find_by_id(self.vacation_id)
      if origin_vacation.present?
        origin_vacation.update(
          :deleted_at=>nil,
          :deleted_uid=>nil,
          :updated_at=>Time.now,
          :updated_uid=>self.updated_uid,
          :reason=>"振休取消," + origin_vacation.reason.to_s
        )
        self.update(:vacation_id=>nil)
        result = origin_vacation
      end
    when 17
      origin_vacation = Vacation.find_by_id(self.vacation_id)
      if origin_vacation.present? && origin_vacation.holiday_work_with_subvacation?
        origin_vacation.update(
          :sts=>4,
          :updated_at=>Time.now,
          :updated_uid=>self.updated_uid,
          :reason=>"代休取消," + origin_vacation.reason.to_s
        )
        self.update(:vacation_id=>nil)
        result = origin_vacation
      end
    end

    result

  end

  # 不要項目の削除（base_noに依存
  def clear_unused_fields(do_update=false)
    clear_fields = {}
    common_fields = [
      "id",   "user_id"  ,"login_id"    ,"branch_cd" ,"vacation_day"  ,
      "vacation_type_id" ,"base_no"     ,"app_at"    ,"authorizer_id" ,
      "authorizer_name"  ,"approval_at" ,"reason"    ,
      "lock_version","created_at","created_uid","updated_at","updated_uid","deleted_at","deleted_uid",
    ]
    require_field_state = [
      {base_no: [6],               require: ["at_work","sts"]},
      {base_no: [7,17],            require: ["origin_date","vacation_id"]},
      {base_no: [2,3,31,32,33,34,41,42], require: ["leav_time","arriv_time"]},
    ]
    require_fields = require_field_state.find{|state| state[:base_no].include?(self.base_no)}&.dig(:require) || []

    unused_fields = self.attribute_names - (common_fields+require_fields)
    unused_fields.each do |key|
      clear_fields[key] = self[key]
      self[key] = nil
    end
    self.update if do_update
    clear_fields
    
  end



  #
  #===公休日初期設定
  def self.set_init6(queue,t_year,t_month,uid)
    job = DelayedJob.find_by_queue(queue)
    msg = DelayedJobMsg.find_by_delayed_job_id(job[:id])
    if msg.blank?
      msg = DelayedJobMsg.new({:delayed_job_id=>job[:id],:queue=>job[:queue]})
    end
    msg[:msg] = "公休日初期設定開始\n法定休日をロード\n" ; msg.save!
    whs = WhSummary.find_by(:t_year=>t_year,:t_month=>t_month)
    if whs.blank?
      msg[:msg] += "公休日カレンダーを登録してください。\n" ; msg.save!
    else
      whcs = WhCalendar.where(:t_date=>[whs[:s_date]..whs[:e_date]],:wh_flg=>1)
      if whcs.blank?
        msg[:msg] += "公休日カレンダーを登録してください。\n" ; msg.save!
      else
        holidaies = whcs.map{|w|w[:t_date]}
        msg[:msg] += "対象作業員をロード\n" ; msg.save!
        menbers = Woker.get_menber_list(whs[:s_date])
        if menbers.blank?
          msg[:msg] += "配番作業員を登録してください。\n" ; msg.save!
        else
          msg[:msg] += "公休日を設定\n" ; msg.save!
          base_no = 6
          vtype = VacationType.select(:id).find_by_base_no(base_no)
          vacation_type_id = vtype[:id]
          #menber_num = menbers.size
          holidaies.each{|vacation_day|
            msg[:msg] += "#{vacation_day.strftime("%Y/%m/%d")}の公休日を登録開始\n" ; msg.save!
            do_count = 0
            menbers.each{|menber|
              self.create_vacation({
                  :user_id => menber["id"],
                  :login_id => menber["login_id"],
                  :branch_cd => menber["branch_cd"],
                  :vacation_day => vacation_day,
                  :vacation_type_id => vacation_type_id,
                  :base_no => base_no,
                  :sts => 0,
                  :created_uid => uid,
                  :updated_uid => uid,
              })
              do_count += 1
              if do_count % 25 == 0
                msg[:msg] += "■" ; msg.save!
              end
            }
            msg[:msg] += "\n#{vacation_day.strftime("%Y/%m/%d")}の公休日を登録完了\n" ; msg.save!
          }
        end
      end
    end
    msg[:msg] += "公休日初期設定が完了しました。\n" ; msg.save!
  end
  #


  #===不足公休日の自動割当_改修用
  def self.set_add6(queue,t_year,t_month,uid,branche_cd=nil)
    job = DelayedJob.find_by_queue(queue)
    msg = DelayedJobMsg.find_by_delayed_job_id(job[:id])
    if msg.blank?
      msg = DelayedJobMsg.new({:delayed_job_id=>job[:id],:queue=>job[:queue]})
    end
    msg[:msg] ||=""
    whs = WhSummary.find_by(:t_year=>t_year,:t_month=>t_month)
    if whs.blank?
      msg[:msg] += "公休日カレンダーを登録してください。\n" ; msg.save!
      msg[:msg] += "不足公休日の自動割り当てが完了しました。\n" ; msg.save!
    end

    whcs = WhCalendar.where(:t_date=>[whs[:s_date]..whs[:e_date]],:wh_flg=>1)
    if whcs.blank?
      msg[:msg] += "公休日カレンダーを登録してください。\n" ; msg.save!
      msg[:msg] += "不足公休日の自動割り当てが完了しました。\n" ; msg.save!
    end

    msg[:msg] += "対象作業員をロード\n" ; msg.save!
    menbers = Woker.get_menber_list(whs[:s_date],branche_cd)
    if menbers.blank?
      msg[:msg] += "配番作業員を登録してください。\n" ; msg.save!
      msg[:msg] += "不足公休日の自動割り当てが完了しました。\n" ; msg.save!
    end


    holidaies = whcs.map{|w|w[:t_date]} # 法定休日リスト
    msg[:msg] = "不足公休日の自動割り当て開始\n法定休日をロード\n" ; msg.save!
    w_branches = menbers.group_by{|row| row["branch_cd"]}.transform_values{|rows| rows.map{|row| row["login_id"]}} # グループ別ログインIDリスト
      
    #乱数初期化
    random = Random.new()
    #作業変数の初期化
    base_no = 6
    vtype = VacationType.select(:id).find_by_base_no(base_no)
    vacation_type_id = vtype[:id]
    login_ids = []   #作業員のlogin_id
    c_can_day = []   #連休の候補日
    i_can_day = []   #連休の以外の候補日
    wokers_hd={}     #作業員毎の全休日
    wokers_ad={}     #作業員毎の追加公休日
    date_hwokers={}  #日付毎の休暇作業員
    menbers.each{|m|
      login_ids << m["login_id"]
      wokers_hd[m["login_id"]]={}
      wokers_ad[m["login_id"]]=[]
    }

    #休暇取得日重み計算用
    week_weight = self.init_week_weight(whs[:s_date],whs[:e_date],whs[:h_setting_min])
    # 月度の前後が公休日の場合を考慮
    tmp_holidaies = holidaies
    WhCalendar.where(:t_date=>[whs[:s_date]-1,whs[:e_date]+1],:wh_flg=>1).each {|wh|
      tmp_holidaies << wh[:t_date]
    }

    wk_date = whs[:s_date]
    while wk_date <= whs[:e_date] do
      date_hwokers[wk_date] = {}
      unless tmp_holidaies.include?(wk_date)
        if tmp_holidaies.include?(wk_date-1) || tmp_holidaies.include?(wk_date+1)
          c_can_day << wk_date
        else
          i_can_day << wk_date
        end
      end
      wk_date+=1
    end
    msg[:msg] += "登録済み公休日をロード\n" ; msg.save!
    vacations = self.where(:vacation_day=>[whs[:s_date]..whs[:e_date]],:login_id=>login_ids)
    vacations.each{|v|
      wokers_hd[v[:login_id]][v[:vacation_day]] = v[:base_no]
      wokers_ad[v[:login_id]] << v[:vacation_day] if v[:base_no] == 6 && !holidaies.include?(v[:vacation_day])  #base_no6ではなく、法定休リストに含まれない
      date_hwokers[v[:vacation_day]][v[:login_id]] = v[:base_no]
    } unless vacations.blank?

    menbers.each{|m|
      # 重み付け初期化
      d_week_weight =  Marshal.load(Marshal.dump(week_weight))
      vac_days = wokers_ad[m["login_id"]]
      vac_days = [vac_days] if vac_days.is_a?(Date)
      vac_days.each {|day| find_and_increment_taken_vacation_count(day,week_weight)}
      #下限に満たない場合
      if wokers_ad[m["login_id"]].size < whs[:h_setting_min]
        msg[:msg] += "#{m["name"]}(#{m["login_id"]})の割り当て開始\n" ; msg.save!
        def_vacation = {
          :user_id => m["id"],
          :login_id => m["login_id"],
          :branch_cd => m["branch_cd"],
          :vacation_type_id => vacation_type_id,
          :base_no => base_no,
          :at_work => 0,
          :sts => 0,
          :created_uid => uid,
          :updated_uid => uid,
        }
        hcontinuous = 0
        wk_c_can_day = Marshal.load(Marshal.dump(c_can_day)) #連休候補
        wk_i_can_day = Marshal.load(Marshal.dump(i_can_day)) #バラ候補
        wokers_hd[m["login_id"]].each{|wk_date,base_no|  #候補日から除外
          if wk_c_can_day.include?(wk_date)
            wk_c_can_day.delete(wk_date)
            hcontinuous += 1 if base_no==6 
            #連休にならないように前後を候補から削除
            wk_i_can_day.delete(wk_date-1)
            wk_i_can_day.delete(wk_date+1)

            #法定休を挟んで休暇を取得しないように候補から削除
            tmp_d = wk_date - 1
            while holidaies.include?(tmp_d) && whs[:s_date] <= tmp_d do
              tmp_d -= 1
            end
            wk_c_can_day.delete(tmp_d)
            wk_i_can_day.delete(tmp_d)
            tmp_d = wk_date + 1
          
            while holidaies.include?(tmp_d) && whs[:e_date] >= tmp_d do
              tmp_d += 1
            end
            wk_c_can_day.delete(tmp_d)
            wk_i_can_day.delete(tmp_d)

          end
          if wk_i_can_day.include?(wk_date)
            wk_i_can_day.delete(wk_date)
            wk_i_can_day.delete(wk_date-1)
            wk_i_can_day.delete(wk_date+1)
            wk_c_can_day.delete(wk_date-1)
            wk_c_can_day.delete(wk_date+1)
          end
        }unless wokers_hd[m["login_id"]].blank?

        #公休設定不可の日付を候補日から除外
        (t_month == 1 ? [t_year-1,t_year] : [t_year]).each{|yyyy|
          BaseNo6NgList.each{|mmdd|
            wk_date = Date.parse("#{yyyy}-#{mmdd}")
            wk_i_can_day.delete(wk_date)
            wk_c_can_day.delete(wk_date)
          }
        }


        #連休設定（上限２）
        (2 - hcontinuous).times{|wi|
          if wk_c_can_day.present?
            if wk_c_can_day.size < 3
              vacation_day =  wk_c_can_day[random.rand(wk_c_can_day.size)]
            else
              r_candidacy = wk_c_can_day.map{|wk_date|
                priority_score = calc_priority_score(wk_date,m,wokers_ad,date_hwokers,w_branches)
                [wk_date, priority_score]
              }.sort_by{|_,score| score}

              max_score = r_candidacy[0][1]
              r_candidacy = r_candidacy.filter{|_,score| score==max_score}
              vacation_day = r_candidacy.shuffle[0][0]

              self.find_and_increment_taken_vacation_count(vacation_day,d_week_weight)
            end

            self.create_vacation(def_vacation.merge({:vacation_day=>vacation_day}))
            wk_c_can_day.delete(vacation_day)
            # 月曜日と土曜日の連休は各1回　候補から削除する
            [wk_c_can_day,wk_i_can_day].each do |can_day|
              can_day.filter!{|wk_date| wk_date.wday()!=vacation_day.wday()}
            end if [1,6].include?(vacation_day.wday)


            #連休にならないように前後を候補から削除
            wk_i_can_day.delete(vacation_day-1)
            wk_i_can_day.delete(vacation_day+1)
            tmp_d = vacation_day - 1
            while holidaies.include?(tmp_d) && whs[:s_date] <= tmp_d do
              tmp_d -= 1
            end
            wk_c_can_day.delete(tmp_d)
            wk_i_can_day.delete(tmp_d)
            tmp_d = vacation_day + 1
            while holidaies.include?(tmp_d) && whs[:e_date] >= tmp_d do
              tmp_d += 1
            end
            wk_c_can_day.delete(tmp_d)
            wk_i_can_day.delete(tmp_d)
            wokers_hd[m["login_id"]][vacation_day] = base_no
            wokers_ad[m["login_id"]] << vacation_day
            date_hwokers[vacation_day][m["login_id"]] = base_no
          end
        }

        #他公休日設定
        (whs[:h_setting_min] - wokers_ad[m["login_id"]].size).times{|wi|
          if wk_i_can_day.present?
            if wk_i_can_day.size < 3
              vacation_day =  wk_i_can_day[random.rand(wk_i_can_day.size)] # << ここでランダムにバラ休候補から日付を指定している
            else

              r_candidacy = wk_i_can_day.shuffle.map{|wk_date|
                priority_score = calc_priority_score(wk_date,m,wokers_ad,date_hwokers,w_branches)
                [wk_date, priority_score]
              }.sort_by{|_,score| score}

              max_score = r_candidacy[0][1]
              r_candidacy = r_candidacy.filter{|_,score| score==max_score}
              vacation_day = r_candidacy.shuffle[0][0]

              self.find_and_increment_taken_vacation_count(vacation_day,d_week_weight)
            end

            self.create_vacation(def_vacation.merge({:vacation_day=>vacation_day}))
            #連休にならないように前後を候補から削除
            wk_i_can_day.delete(vacation_day-1)
            wk_i_can_day.delete(vacation_day)
            wk_i_can_day.delete(vacation_day+1)
            wk_c_can_day.delete(vacation_day-1)
            wk_c_can_day.delete(vacation_day+1)
            wokers_hd[m["login_id"]][vacation_day] = base_no
            wokers_ad[m["login_id"]] << vacation_day
            date_hwokers[vacation_day][m["login_id"]] = base_no
          end
        }
      end

      d_week_weight = nil
    }  #menbersのループ
    msg[:msg] += "不足公休日の自動割り当てが完了しました。\n" ; msg.save!
  end



  def self.init_week_weight(s_date,e_date,max_vacation_limit)
    range = (s_date..e_date).to_a
    sun_index = range.map(&:wday).find_index{|wday| wday==0}
    sun_to_sat_list = []
    s = 0; e = sun_index;
    (range.size/7.0).ceil.times do |i|    
      sun_to_sat_list << range[s..e]
      s=e+1; e+=7
    end
    week_weight =sun_to_sat_list.map.with_index{|sun_to_sat,index|
      key = "w#{index}"
      data = {
        "days" => sun_to_sat,
        "week_days_count" => sun_to_sat.size,
        "taken_vacation_count"=> 0,
        "max_vacation_limit"=> max_vacation_limit,
        "vacation_priority_weight" => 0
      }
      [key,data]
    }.to_h
    week_weight

  end

  # 休暇取得日候補　優先度計算
  def self.calc_priority_score(t_date,member,wokers_ad,date_hwokers,w_branches)

    # A: 全体の休暇者数
    all_day_count = date_hwokers[t_date].size
  
    # B: グループ内の休暇者数
    lid = member["login_id"]
    b = member["branch_cd"]
    branch_members = w_branches[b]
    group_day_count = date_hwokers[t_date].filter{|l,_| branch_members.include?(l)}.size
    
    # C: 自分の週の休暇数
    iso_week = t_date.cweek
    self_week_count = wokers_ad[lid].filter{|d| d.cweek==iso_week}.size

    
    # スコア計算（小さい方が優先）
    score = 1.0 * all_day_count + 2.5 * group_day_count + 10.0 * self_week_count
    wdayw = weekday_weight(t_date.wday)
    return score*wdayw
  end

  def self.weekday_weight(wday)
    case wday
    when 1
      return 1.2
    when 6
      return 0.8
    else
      return 1.0
    end
  end

  def self.set_vacation_priority_weight(week_weight_value)
    # --- 係数(重み付けの調整) ---
    vacation_multiplier = 1
    days_multiplier     = 1
    days, week_days_count, taken_vacation_count, max_vacation_limit \
        = week_weight_value.values_at("days","week_days_count","taken_vacation_count","max_vacation_limit")
    weight = (1 - taken_vacation_count.to_f / max_vacation_limit.to_f) * vacation_multiplier + (1 / week_days_count.to_f) * days_multiplier
    week_weight_value["vacation_priority_weight"] = weight

    return [weight,week_weight_value]
  end

  def self.get_week_weight_key(day,week_weight)
    key = nil
    found = week_weight.find{|key,data| data["days"].include?(day)} #=>[key,value] 
    key = found[0] if found.present?
    key
  end

  def self.get_vacation_priority_weight(key,week_weight)
    week_weight[key]["vacation_priority_weight"]
  end

  def self.find_and_increment_taken_vacation_count(day,week_weight)
    key = self.get_week_weight_key(day,week_weight)
    return unless key
    week_weight[key]["taken_vacation_count"]+=1
  end




  #
  #===休暇承認済みか返す
  def is_authorize?
    return (self[:sts] == 1)
  end
  #
  #===カレンダー表示文言
  def str_col_vacation_type(type_list=nil?)
    if type_list.present?
      str_vacation_type = type_list["#{self[:vacation_type_id]}"]
    else
      str_vacation_type = self.vacation_type.try(:time_sheet_name)
    end
    case self[:base_no]
    when 2,3
      ret = str_vacation_type.slice(0,2)
    when 14,16,19,20   #14=公傷、16=結婚、19=出停、20=通災
      ret = str_vacation_type.slice(-1,1)
    when 9,21 #「特」はじまり判別のため
      ret = str_vacation_type.slice(0,2)
    when 31,32,33,34,41,42
      ret = str_vacation_type.slice(0,2)
    else
      ret = str_vacation_type.slice(0,1)
    end
    if self[:base_no] == 6  #公休
      ret << Vacation.list_to_str(KAFUKA_MARK,"#{self[:at_work]}")
    end
    return ret
  end
  #
  #===ステータス文字列
  def str_sts
    return Vacation.list_to_str(Sts,"#{self[:sts]}")
  end

  #===休日出勤?
  def holiday_work?()
    return self.base_no == 6 && (self.sts == 4 || self.sts == 5)    
  end
  #===代休取得済?
  def holiday_work_with_subvacation?()
    return self.base_no == 6 && self.sts == 5    
  end
  

  # 
  #===当日の出勤有無 
  def works_on?()
    base_no = self[:base_no]
    return false if base_no.blank?
    return [2,3,31,32,33,34,41,42].include?(base_no)

  end
  #
  #===配番用休暇申請リスト
  def self.get_assignment_list(t_date)
    ret = {}
    vacations = self.where({:vacation_day=>t_date})
    vacations.each{|vacation|
      vacation_data = {}
      [:vacation_type_id,:base_no,:at_work,:origin_date,:arriv_time,:leav_time].each{|key|
        vacation_data[key] = vacation[key]
      }
      ret[vacation[:login_id]] = vacation_data
    }unless vacations.blank?
    return ret
  end


  #===必要人数表、配番人数表の休暇集計表用データ
  def self.get_wokers_vacation_totalling_list(t_date)
    vac_table_data = {}
    temp_vacation_list = [0,0,0,0,0,0] # 在籍,公休,明休,年休,出勤,公出
    branches =  Branche.cargo_work_group.map{ |branch| [branch.cd, branch] }.to_h
    branches.each do |b_cd,branch|
      template = {}
      [:fm,:op,:wk].each {|h_key| template[h_key] = temp_vacation_list.dup}
      vac_table_data[b_cd.to_s] = {name: branch[:name], datas: template}
    end
    t_date_vacations = Vacation.where(:vacation_day=>t_date).pluck(:login_id).zip(Vacation.where(:vacation_day=>t_date)).to_h
    all_wokers = Woker.get_latest(t_date)
    all_wokers.each do |woker|
      woker_type = woker.get_woker_type()
      if vac_table_data[woker[:branch_cd]] && woker_type.present?
        vac_table_data[woker[:branch_cd]][:datas][woker_type][0] +=1 #在籍に＋１
        vac_state = Vacation.get_vac_stat(t_date_vacations[woker[:login_id]])
        vac_table_data[woker[:branch_cd]][:datas][woker_type][vac_state] +=1 if vac_state
        vac_table_data[woker[:branch_cd]][:datas][woker_type][1] +=1 if vac_state==5 # UAT-221 「公出」の場合、「公休」もカウントアップ
      end
    end
    return vac_table_data

  end


#
  #===テスト用休暇日登録
  def self.mk_test_vacation(tdates,is_authorized = true)
    ret = {}
    #乱数初期化
    random = Random.new()
    #期間
    term =[tdates[:length][:begin_date]..tdates[:length][:end_date]]
    #従業員No->ユーザIDのリスト
    userid_list = User.getdatalist({:key=>:login_id,:text=>:id,:type=>'hash'})
    #休暇種別No→IDのリスト
    vtype_list = VacationType.getdatalist({:key=>:base_no,:text=>:id,:type=>'hash'})
    #休暇種別ランダム用
    base_nos = vtype_list.keys
    base_nos.delete("1")
    base_nos.delete("2")
    
    #登録済み休暇申請をロード
    vacation_data={}    #日付毎の休暇申請
    woker_vacation={}   #ユーザ毎の休暇申請件数
    vacations = self.where({:vacation_day=>term})
    vacations.each{|vacation|
      vacation_data[vacation[:vacation_day]] ||= {}
      vacation_data[vacation[:vacation_day]][vacation[:login_id]] = vacation
      woker_vacation[vacation[:login_id]] ||= {:wk=>0,:hd=>0}
      if vacation[:base_no]==1
        woker_vacation[vacation[:login_id]][:wk]+=1
      else
        woker_vacation[vacation[:login_id]][:hd]+=1
      end
    }unless vacations.blank?
    #休暇日をロード
    holidaies = WhCalendar.where(:wh_flg=>1,:t_date=>term).map{|wh| wh[:t_date]}
    #グループ毎に
    #おおよそ１G50名
    #公休日は100名ほど必要＝25名/1G出勤要請(3回まで
    #平日は200名ほど必要＝10名/1G休暇、1名早退とする（5回まで
    Branche::WorkerBranchCd.each{|branch_cd|
      wokers = Woker.select(:login_id).where(:applicable=>Applicable.get_applicable(2,tdates[:length][:begin_date]),:branch_cd=>branch_cd).map{|woker|woker[:login_id]}
      #公休日出勤依頼を設定
      holidaies.each{|holiday|
        l_wokers = Marshal.load(Marshal.dump(wokers))
        #該当日に休暇申請を行っている作業員を候補者から除外
        vacation_data[holiday].each{|login_id,vd|
          l_wokers.delete(login_id) if vd[:base_no]==1
        } if vacation_data.has_key?(holiday)
        #10名を休日出勤させるまで繰り返す
        while wokers.size - l_wokers.size < 25 do
          t_woker =  l_wokers[random.rand(l_wokers.size)]
          is_create = false
          if woker_vacation.has_key?(t_woker)
            is_create = (woker_vacation[t_woker][:wk] < 4)
          else
            woker_vacation[t_woker]={:wk=>0,:hd=>0}
            is_create = true
          end
          if is_create
            vacation = {
              :user_id=>userid_list[t_woker],
              :login_id=>t_woker,
              :branch_cd=>branch_cd,
              :vacation_day=>holiday,
              :vacation_type_id=>vtype_list["1"],
              :base_no=>1,
              :app_at=>Time.now(),
              :sts=>0,
              :created_uid=>"test",
              :updated_uid=>"test",
            }
            if is_authorized
              vacation[:sts] = 1
              vacation[:authorizer_id] = 0
              vacation[:authorizer_name] = "test"
              vacation[:approval_at] = Time.now()
            end
            self.create(vacation)
            l_wokers.delete(t_woker)
            woker_vacation[t_woker][:wk] += 1
          end
        end
      }unless holidaies.blank?
      #休暇申請を実行
      wk_date=tdates[:length][:begin_date]
      while wk_date<=tdates[:length][:end_date] do
        unless holidaies.include?(wk_date)
          l_wokers = Marshal.load(Marshal.dump(wokers))
          has_early = false
          #該当日に休暇申請を行っている作業員を候補者から除外
          vacation_data[wk_date].each{|login_id,vd|
            l_wokers.delete(login_id)
            has_early = true if vd[:base_no]==2
          } if vacation_data.has_key?(wk_date)
          #5名を休暇申請させるまで繰り返す
          while wokers.size - l_wokers.size < 5 do
            t_woker =  l_wokers[random.rand(l_wokers.size)]
            is_create = false
            if woker_vacation.has_key?(t_woker)
              is_create = (woker_vacation[t_woker][:hd] < 6)
            else
              woker_vacation[t_woker]={:wk=>0,:hd=>0}
              is_create = true
            end
            if is_create
              base_no = base_nos[random.rand(base_nos.size)]
              vacation = {
                :user_id=>userid_list[t_woker],
                :login_id=>t_woker,
                :branch_cd=>branch_cd,
                :vacation_day=>wk_date,
                :vacation_type_id=>vtype_list[base_no],
                :base_no=>base_no,
                :app_at=>Time.now(),
                :sts=>0,
                :created_uid=>"test",
                :updated_uid=>"test",
              }
              case base_no
              when "6" ; vacation[:at_work] = random.rand(1)+1
              when "7" ; vacation[:origin_date] = (wk_date  - 1 - random.rand(8))
              end
              if is_authorized
                vacation[:sts] = 1
                vacation[:authorizer_id] = 0
                vacation[:authorizer_name] = "test"
                vacation[:approval_at] = Time.now()
              end
              self.create(vacation)
              l_wokers.delete(t_woker)
              woker_vacation[t_woker][:hd] += 1
            end
          end
          #1名を早退にしたりしなかったり
          if has_early==false && random.rand(3) == 1
            t_woker =  l_wokers[random.rand(l_wokers.size)]
            leav_time = 14 - random.rand(3)
            vacation = {
                :user_id=>userid_list[t_woker],
                :login_id=>t_woker,
                :branch_cd=>branch_cd,
                :vacation_day=>wk_date,
                :vacation_type_id=>vtype_list["2"],
                :base_no=>2,
                :leav_time=>"#{format("%02d",leav_time)}:00",
                :app_at=>Time.now(),
                :created_uid=>"test",
                :updated_uid=>"test",
              }
            if is_authorized
              vacation[:sts] = 1
              vacation[:authorizer_id] = 0
              vacation[:authorizer_name] = "test"
              vacation[:approval_at] = Time.now()
            end
            self.create(vacation)
          end
        end
        wk_date += 1
      end
    }
    return ret
  end

  #== 振休、代休取得可否チェック
  # 
  def can_take_vacation(to_date,base_no,is_manager=false,over_write=false)
    # エラーコード一覧（HTTPライクなコードに変更）
    # code: 400, msg: "「振休」または「代休」以外が選択されています。"  # 7,17以外のbase_noが選択された場合
    # code: 422, msg: "休暇取得日は本日以降を指定してください。"           # 取得日が未来日でない場合（管理者以外）
    # code: 409, msg: "指定の休暇取得日(#{to_date.strftime("%m/%d")})には既に『#{vt[:time_sheet_name]}』が登録されています。" # 取得日に既に休暇が登録されている場合
    # code: 403, msg: "公休のみ#{vt[:time_sheet_name]}の取得が可能です。" # 公休以外から振休・代休を取得しようとした場合
    # code: 422, msg: "指定の#{sub_vac_col_name[base_no]}は法定休日です。" # 振休元日が法定休日の場合
    # is_manager => trueの場合、チェック条件が緩和
    # over_write => trueの場合、取得日に休暇が登録されている場合もチェックをスキップ
    
    ret = {:result=>200, :msg=>""}

    return {:result=>403, :msg=>"「振休」または「代休」以外が選択されています。"} unless [7,17].include?(base_no)
    vt = VacationType.find_by_base_no(base_no)
    sub_vac_col_name = {7=>"振替元日",17=>"休日出勤日"}
    t_user = User.find(self[:user_id])

    # 取得日が未来日であること　---(1)
    if !is_manager && to_date < Date.today()
      ret = {result: 422, msg:"休暇取得日は本日以降を指定してください。"}; return ret
    end

    # 取得日に休暇が登録されていないこと
    unless over_write
      t_date_vacation = Vacation.find_by(:user_id=>t_user[:id],:vacation_day=>to_date)
      if t_date_vacation.present?
        vt = VacationType.find_by_base_no(t_date_vacation[:base_no])
        ret = {result: 409, msg:"指定の休暇取得日(#{to_date.strftime("%m/%d")})には既に『#{vt[:time_sheet_name]}』が登録されています。"}; return ret
      end
    end


    unless self[:base_no]==6
      ret = {result: 403, msg:"公休のみ#{vt[:time_sheet_name]}の取得が可能です。"}; return ret
    end

    case base_no.to_i
    when 7 # 振休
      # 「振休」の設定のルール
      wh = WhCalendar.find_by(:t_date=>self[:vacation_day])
      if wh[:wh_flg]==1
        ret = {result: 422, msg:"指定の#{sub_vac_col_name[base_no]}は法定休日です。"}; return ret
      end

      
      # 連動は連動、バラはバラ
      adjacent_vacations = [1,-1].map{|offset| Vacation.find_by(:user_id=>t_user[:id],:vacation_day=>(self[:vacation_day]+offset),:base_no=>6)}
      # バラ------
      # バラはバラにのみ⇒前後に法定休および指定休がないこと
      if adjacent_vacations.all?(&:nil?)
        adjacent_to_vacations = [1,-1].map{|offset| 
          found_vac = Vacation.find_by(:user_id=>t_user[:id],:vacation_day=>(to_date+offset),:base_no=>6)
          if found_vac.present?
            found_vac[:id]==self[:id] ? nil : found_vac
          else
            nil
          end
        }
        unless adjacent_to_vacations.all?(&:nil?)
          wday = self[:vacation_day].wday
          # ret = {result: false, msg:"法定休前後日の#{to_date.strftime("%m/%d(#{I18n.t("date.abbr_day_names")[to_date.wday]})")}に#{self[:vacation_day].strftime("%m/%d(#{I18n.t("date.abbr_day_names")[wday]})")}の振休は登録できません。"}; return ret
          # 
          # ret = {result: false, msg:"法定休日と連続しない#{sub_vac_col_name[base_no]}を指定しています。\n取得対象日は法定休日と連続しない日を指定してください。"}; return ret

        end
      end


      # 連動------
      # 前後の法定休取得
      adjacent_legal_vacations = adjacent_vacations.map do |vacation|
        next nil if vacation.blank?
        wh = WhCalendar.find_by(:t_date=>vacation[:vacation_day], :wh_flg=>1)
        if wh.present?
          next vacation
        else
          next nil
        end
      end

      # 元休暇が連動指定休の場合
      if adjacent_legal_vacations.any?(&:present?)
        # 振替先の前後に法定休があるか調べる
        to_date_adjacent_legal_vacations = [1,-1].map do |offset|
          v = Vacation.find_by(:user_id=>t_user[:id],:vacation_day=>(to_date+offset),:base_no=>6)
          next nil if v.blank?
          wh = WhCalendar.find_by(:t_date=>v[:vacation_day], :wh_flg=>1)
          next nil if wh.blank?
          next v
        end

        # ↓ない場合、エラー
        if to_date_adjacent_legal_vacations.all?(&:nil?)
          wday = self[:vacation_day].wday()
          # msg = "火曜日～金曜日に"
          # msg += "法定休前後日の#{self[:vacation_day].strftime("%m/%d(#{I18n.t("date.abbr_day_names")[wday]})")}の振休は登録できません。"
          # ret = {result: false, msg:msg}; return ret
        end

        
        to_date_adjacent_legal_vacations.each.with_index do |vac,index|
          step = [1,-1][index]
          next if vac.blank? # 公休登録なし⇒nil
  
          # 公休登録かつ法定休日の場合↓
          next_wk_day = nil; wk_day = vac[:vacation_day] + step
          while next_wk_day.blank? do
            wh = WhCalendar.find_by(:t_date=>wk_day,:wh_flg=>0)
            if wh.present?
              next_wk_day = wk_day
            else
              wk_day += step
            end
          end
  
          wk_day_vacation = Vacation.find_by(:user_id=>t_user[:id],:vacation_day=>next_wk_day,:base_no=>6)
          if wk_day_vacation.present? && wk_day_vacation[:id]!=self[:id]
            ret = {result: 422, msg:"既に法定休日(#{vac[:vacation_day].strftime("%m/%d")})に連続する公休が登録されています。"}; return ret
          end
        end
        
      end
      return ret
    when 17 # 代休
      unless self.holiday_work? # 休日出勤であるか？
        ret = {result: 422, msg:"指定の#{sub_vac_col_name[base_no]}に休日出勤の登録がありません。"}; return ret
      end
      if self.holiday_work_with_subvacation? # 代休未取得であるか？
        sub_vac = Vacation.find_by(:user_id=>self.user_id,:vacation_id=>self.id)
        if sub_vac.present?
          ret = {result: 409, msg:"指定の休日出勤(#{self.vacation_day.strftime("%m/%d")})は#{sub_vac.vacation_day.strftime("%m/%d")}に代休取得済です。"}; return ret
        else
          ret = {result: 409, msg:"指定の休日出勤(#{self.vacation_day.strftime("%m/%d")})は代休取得済です。"}; return ret
        end
      end
      return ret
    else
      ret = {result: 500, msg:"未想定のエラーが発生しました。"}
      return ret
    end
    return ret
  end


  def self.get_hol_work_vacation(user_id,include_with_subvacation=false)
    # 3か月以上前の休日出勤は振替不可とした（2024-12-6 大澤)
    # include_with_subvacation=>trueで代休取得済の休日出勤を含む
    t_sts = include_with_subvacation ? [4,5] : [4]
    limit = Date.today.ago(3.month)
    ret_vacation = Vacation.where(:user_id=>user_id,:base_no=>6,:sts=>t_sts).where("vacation_day >= ?",limit).order(:vacation_day)
    ret_vacation
  end

  def self.get_base6(user_id, wh:nil,where:[])
    ret_vacation = Vacation.where(:user_id=>user_id,:base_no=>6)
    where.each do |condition,value|
      ret_vacation = ret_vacation.where(condition,value)
    end
    if ret_vacation.present? && wh.present?
      wh = WhCalendar.where(:t_date=>ret_vacation.pluck(:vacation_day),:wh_flg=>wh)
      ret_vacation = ret_vacation.where(:vacation_day=>wh.map(&:t_date))
    end
    ret_vacation
  end
  #== 必要人数表、配番人数表用
  def self.get_vac_stat(vac)
    # 1から順に　公休,明休,年休,出勤,公出
    sts_1_list = [["6","公休"],["7","振休"],["9","特休"],["10","夏休"],["17","代休"]]
    sts_2_list = [["18", "明休"]]
    # UAT-279: 看護・介護・年休の分類を4から3に変更
    sts_3_list = [["8", "年休"],["11", "産休"],["12", "忌引"],["13", "病欠"],["14", "公傷"],["15", "組休"],["16", "結婚"],["19", "出停"],["20", "通災"],["21", "特年"],["22", "欠勤"],["23", "看護"],["24", "介護"],["25", "育休"]] + [["31", "看Ａ"], ["32", "看Ｐ"], ["33", "介Ａ"], ["34", "介Ｐ"], ["41", "年Ａ"], ["42", "年Ｐ"]]
    sts_4_list = [["2", "早遅"],["3", "遅出"]]

    
    return 4 unless vac
    return 5 if (vac.base_no == 6 && vac.at_work== 1)
    return 1 if sts_1_list.find{|base_no,nm| base_no.to_i==vac.base_no}.present?
    return 2 if sts_2_list.find{|base_no,nm| base_no.to_i==vac.base_no}.present?
    return 3 if sts_3_list.find{|base_no,nm| base_no.to_i==vac.base_no}.present?
    return 4 if sts_4_list.find{|base_no,nm| base_no.to_i==vac.base_no}.present?
    return nil
  end

  def origin_vacation(deleted=false)
    return nil if !(self.base_no==7 or self.base_no==17)
    return nil if self.vacation_id.blank?
    if deleted
      origin_vacation = Vacation.unscoped.find_by(:id=>self.vacation_id)
    else
      origin_vacation = Vacation.find_by(:id=>self.vacation_id)
    end
    origin_vacation
      
  end

  def at_work_str()
    return "" if self.at_work.blank? || self.at_work==0
    return "〇" if self.at_work==1
    return "×" if self.at_work==2
  end




end
