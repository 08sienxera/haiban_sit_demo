# coding: utf-8
class User < ApplicationRecord
  extend Common::Func
  default_scope {where(:deleted_at => nil)}
  has_one :user_auth, primary_key: :login_id, foreign_key: :login_id
  has_one :woker, primary_key: :login_id, foreign_key: :login_id
  has_many :vacations, class_name: 'Vacation',  primary_key: :login_id, foreign_key: :login_id
  
  
  #--
  #===定数
  #++
  # 休暇申請リマインド受信設定
  HolidayMailFlg = [["受信しない","0"],["受信","1"]]
  # 権限フラグリスト
  AuthFlg = [["現場職","0"],["事務職","2"],["親方","3"],["管理課","4"]]
  # 掲示メール受信設定
  BbsMailFlg = [["受信しない","0"],["重要のみ","1"],["全て受信","2"]]
  # 基本表示掲示件数
  DefaultBbsMaxCount = 10
  # SIT管理ユーザ
  SIT_Admin = "xadmin"
  # 初期リマインド質問
  DefaultRemindQuestion = "小名浜港の港湾荷役といえば？" 
  # 初期リマインド回答
  DefaultRemindAnswer = "小名浜海陸運送"
  
  #
  #===セッターメソッド　オーバーライド
  # def mail=(mail)
  #   self[:mail] = mail.blank? ? nil : mail
  # end
  # def tel=(tel)
  #   self[:tel] = tel.blank? ? nil : tel
  # end
    
  #
  #=== パスワードハッシュ処理
  before_save do
    if self[:password].blank? || self.password.length==32
      self[:password] = self.password_was.blank? ? "" : self.password_was
    else
      self[:password] = Digest::MD5.new.update(self[:password]).to_s
    end
    # self.attributes.each {|key,val| self[key]=nil if val==''}
  end
  #=== 利用可能機能設定データを追加
  after_create :mk_user_auth
  #=== 利用可能機能設定データを追加
  after_update :mk_user_auth

  #
  #===ログイン画面入力フォームの生成
  def self.set_login_form(form_key = "login")
    form = Common::CommonClass.new(form_key)
    form.setparams('login_id',{'title'=>self.human_attribute_name(:login_id),'type'=>'textA','size'=>'20','maxlength'=>'16','inputFlg'=>1,'essFlg'=>1})
    form.setparams('password',{'title'=>self.human_attribute_name(:password),'type'=>'textPass','size'=>'20','maxlength'=>'32','inputFlg'=>1,'essFlg'=>1})
    return form
  end

  #===Login_id入力フォームの生成
  def self.set_remind_form(form_key = "remind")
    form = Common::CommonClass.new(form_key)
    form.setparams('login_id',{'title'=>self.human_attribute_name(:login_id),'type'=>'textA','size'=>'20','maxlength'=>'16','inputFlg'=>1,'essFlg'=>1})
    return form
  end
  #
  #===回答フォームの生成
  def self.set_answer_form(form_key = "answer")
    form = Common::CommonClass.new(form_key)
    form.setparams('remind_question',{'title'=>self.human_attribute_name(:remind_question),'type'=>'textJ','size'=>'35','maxlength'=>'32','inputFlg'=>0,'essFlg'=>0})
    form.setparams('remind_answer',{'title'=>self.human_attribute_name(:remind_answer),'type'=>'textJ','size'=>'35','maxlength'=>'32','inputFlg'=>1,'essFlg'=>1})
    return form
  end

  #
  #===入力画面フォームの生成
  def self.set_input_form(key)
    form = Common::CommonClass.new(key)
    branch_list = Branche.getdatalist({:key=>:cd,:text=>:name,:where=>{:applicable=>Applicable.get_applicable(1)},:order=>:desp_index,:all=>""})
    form.setparams("login_id",{"title"=>self.human_attribute_name(:login_id),"type"=>"textA",'size'=>"20","maxlength"=>"16","inputFlg"=>1,"essFlg"=>1,"align"=>"L"})
    form.setparams("name",{"title"=>self.human_attribute_name(:name),"type"=>"textJ",'size'=>"32","maxlength"=>"32","inputFlg"=>1,"essFlg"=>1,"align"=>"L"})
    form.setparams("password",{"title"=>self.human_attribute_name(:password),"type"=>"textX",'size'=>"32","maxlength"=>"16","inputFlg"=>1,"essFlg"=>1,"align"=>"L"})
    form.setparams("bbs_max_count",{"title"=>self.human_attribute_name(:bbs_max_count),"type"=>"textN",'size'=>"3","maxlength"=>"2","inputFlg"=>1,"essFlg"=>1,"align"=>"R","defVal"=>10})
    form.setparams("auth_flg",{"title"=>self.human_attribute_name(:auth_flg),"type"=>"radio",'size'=>"8","maxlength"=>"8","inputFlg"=>1,"essFlg"=>1,"align"=>"L","list"=>AuthFlg,"defVal"=>"0"})
    form.setparams("branch_cd",{"title"=>"担当グループ","type"=>"select",'size'=>"9","maxlength"=>"8","inputFlg"=>1,"essFlg"=>0,"align"=>"C","list"=>branch_list})
    return form
  end
  #
  #===更新画面フォームの生成
  def self.set_edit_form(key)
    form = self.set_input_form(key)
    form.setparam('password','essFlg',0)
    form.setparam('password','fwd',"変更時のみ設定してください<br />")
    return form
  end
  #
  #===CSVフォームの生成
  def self.set_csv_form(key)
    form = self.set_input_form(key)
    form.setparam('password','essFlg',0)
    form.setparam('password','csvForcedVal',"")
    form.setparam('password','exp',"新規登録／変更時のみ設定してください")
    list = form.getparamdata('branch_cd','list')
    list[0]=["なし",""]
    form.setparam('branch_cd','list',list)
    form.setparam('branch_cd','exp',"権限フラグが「親方」の場合に設定してください<br />".html_safe)
    return form
  end
  #
  #===一覧画面フォームの生成
  def self.set_list_form(key)
    form = self.set_input_form(key)
    skeys = ["login_id","name","auth_flg","branch_cd"]
    pkeys = Marshal.load(Marshal.dump(form.getparamkey))
    pkeys.each {|pkey|
      form.unsetparams(pkey) unless skeys.include?(pkey)}
    form.set_all_param("inputFlg",0)
    form.set_all_param("essFlg",0)
    form.setparam('auth_flg','type',"select")

    form.setparams('id',{'title'=>'ID','type'=>'hidden','size'=>'20','maxlength'=>'16','inputFlg'=>0,'essFlg'=>0,'align'=>'R','noserch'=>"1"})
    form.set_index('id',0)
    form.setparam('login_id','link',{:action=>:edit,:id=>'id'})
    if Rails.env.development?
      form.setparams("last_logined_at",{"title"=>self.human_attribute_name(:last_logined_at),"type"=>"textD",'size'=>"10","maxlength"=>"10","inputFlg"=>0,"essFlg"=>0,"align"=>"C",
        "format"=>"%y/%m/%d","link"=>{:action=>:show,:id=>'id',:opt=>"reset"}})
    end
    return form
  end
  #
  #===ユーザ検索フォームの生成
  def self.set_serch_form(key)
    #[AuthFlg].each{|list| list.delete(SERCH_ALL) if list.index(SERCH_ALL).present? }

    form = Common::CommonClass.new(key)
    branch_list = Branche.getdatalist({:key=>:cd,:text=>:name,:where=>{:applicable=>Applicable.get_applicable(1)},:order=>:desp_index,:all=>":all"})
    form.setparams("login_id",{"title"=>self.human_attribute_name(:login_id),"type"=>"textA",'size'=>"20","maxlength"=>"16","inputFlg"=>1,"essFlg"=>0,"align"=>"L",
      'serch_field'=>"users.login_id"})
    form.setparams("name",{"title"=>self.human_attribute_name(:name),"type"=>"textJ",'size'=>"32","maxlength"=>"32","inputFlg"=>1,"essFlg"=>0,"align"=>"L",
      'serch_field'=>"users.name"})
    form.setparams("auth_flg",{"title"=>self.human_attribute_name(:auth_flg),"type"=>"select",'size'=>"8","maxlength"=>"8","inputFlg"=>1,"essFlg"=>0,"align"=>"L",
      "list"=>[SERCH_ALL]+AuthFlg,'serch_field'=>"users.auth_flg"})
    form.setparams("branch_cd",{"title"=>"担当グループ","type"=>"select",'size'=>"9","maxlength"=>"8","inputFlg"=>1,"essFlg"=>0,"align"=>"C","list"=>branch_list,
      'serch_field'=>"users.branch_cd"})

    form.setparams("s_name",{"title"=>Woker.human_attribute_name(:s_name),"type"=>"textJ",'size'=>"8","maxlength"=>"8","inputFlg"=>1,"essFlg"=>0,"align"=>"L",
      'serch_field'=>"wokers.s_name"})
    form.setparams("wk_branch_cd",{"title"=>Woker.human_attribute_name(:branch_cd),"type"=>"select",'size'=>"9","maxlength"=>"8","inputFlg"=>1,"essFlg"=>0,"align"=>"L","list"=>branch_list,
      'serch_field'=>"wokers.branch_cd"})

    s_form = Common::CommonClass.new(key)
    s_form.set_serch_params(form)
    return s_form
  end

  #===ログインチェック処理
  # 引数:: params Hash POSTデータ
  # :: strwhere String 追加条件文
  # 戻り値 ::　Booleam (True=ログインOK,False=ログイン処理なし)
  def self.login_check(params,form,strwhere = nil)
    #インスタンス確認
    raise BadRequestError.new if form.blank?
    #ログイン実行チェック
    return nil if params[form.getgname()].nil?
    #ＰＯＳＴデータ確認
    raise ValidateParamsError.new unless form::setpostdata(params)
    #DBデータとの照合
    user = self.find_by(["login_id = ? #{strwhere.blank? ? "" : " And #{strwhere} "}",
        form::getparamdata('login_id','value')])
    if user.blank? || user[:password] != Digest::MD5.new.update(form.getparamdata('password','value')).to_s
      raise LoginCheckError.new
    else
      ret_data = Hash.new
      [:id,:login_id,:name,:bbs_max_count,:auth_flg].each do |key|
        ret_data[key] = user[key]
      end
      return ret_data
    end
  end
 
  #==== 引数パスワードがユーザパスワードと一致するか返す
  def match_password?(password)
    self.password == User.password_to_hash(password)
  end
  def self.password_to_hash(password_str)
    return Digest::MD5.new.update(password_str).to_s
  end
  def self.password_is_valid?(password_str)
    if password_str.match?(/^.{6,}$/) && password_str.match?(/\d/) && password_str.match?(/[a-zA-Z]/)
      return true
    else
      return false
    end
  end


  #==== パスワードをランダムパスワードに変更
  def reset_password()
    new_password = nil
    User.transaction do
      new_password = User.create_random_password
      self.password = new_password
      self.last_logined_at =nil
      self.save
      # メール通知は要件外
      # UserMailer.with(user: self,password: new_password).notify_new_password_mail.deliver_now if self.mail.present?
    end
    return new_password
  end

  #==== 基本表示掲示件数を取得、未設定の場合、基本値を返す
  def get_bbs_max_count
    return self.bbs_max_count ||= DefaultBbsMaxCount
  end

  #==== 指定日が稼働日か返す
  def workday?(t_date)
    wh = WhCalendar.find_by_t_date(t_date)
    vacation = Vacation.find_by(login_id:self.login_id,vacation_day:t_date,sts:1)
    if wh&.wh_flg==0
      vacation.blank? || vacation.base_no == 1
    else
      vacation&.base_no == 1
    end
  end

  #==== ユーザのリマインド質問を返す
  #引数に指定したIDのユーザが存在しない、または指定ユーザにリマインド質問が未登録の場合
  #デフォルト質問を返す
  def self.get_remind_question(login_id)
    user = User.find_by_login_id(login_id)
    if user && user.remind_question.present?
      user.remind_question
    else
      DefaultRemindQuestion
    end
  end

  #==== パスワードリマインドに回答し、結果を真偽値で返す
  def answer_remind_question(answer)
    case self.remind_question
    when nil then
      # user.questionがnilの場合はデフォルト質問に対応する回答で検証
      if answer == DefaultRemindAnswer
        return true
      else
        return false
      end
    else
      if self.remind_answer == answer
        return true
      else
        return false
      end
    end
  end
  
  def woker_for(t_date=Date.today)
    woker = Woker.find_by(login_id: self.login_id, applicable: Applicable.get_applicable(2, t_date))
    woker
  end



  private
  def self.create_random_password()
    password_size = 6
    arrs = []
    arrs << ('a'..'z').to_a
    arrs << ('A'..'Z').to_a
    arrs << (0..9).to_a
    arrs = arrs.flatten
    begin
        password = ''
        password_size.times do
            password += arrs[rand(arrs.length)].to_s
        end
    end until password_is_valid?(password)
    password
    
  end
  #
  #==親方・事務職 利用可能機能設定の作成／削除
  def mk_user_auth
    ua = UserAuth.unscoped.find_by_login_id(self[:login_id])
    if self[:deleted_at].present? && ua.present?
      #削除されたら権限設定も削除
      ua[:deleted_at] = self[:deleted_at]
      ua[:deleted_uid] = self[:deleted_uid]
      ua.save
    elsif [2,3].include?(self[:auth_flg])
      if ua.blank?
        #事務職・親方で権限設定が無い場合は全て不可で新規作成
        ua = {
          :login_id => self[:login_id],
          :created_uid => self[:updated_uid],
          :updated_uid => self[:updated_uid],
        }
        UserAuth::AuthList.each{|key| ua[key] = 2}
        UserAuth.create(ua)
      elsif ua[:deleted_at].present?
        #事務職・親方で権限設定が過去に登録され、論理削除されている場合は復活
        ua[:deleted_at] = nil
        ua.save
      end
    elsif ua.present? && ua[:deleted_at].nil?
      #事務職・親方以外で権限設定がある場合は論理削除
      ua[:deleted_at] = Time.now()
      ua[:deleted_uid] = self[:updated_uid]
      ua.save
    end
  end


end
