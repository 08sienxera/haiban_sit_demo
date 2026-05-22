# coding: utf-8
class Board < ApplicationRecord
  extend Common::Func
  default_scope {where(:deleted_at => nil)}
  has_one :board_group , primary_key: :board_group_id, foreign_key: :id
  has_one :board_category ,primary_key: :board_category_id, foreign_key: :id
  has_many :board_target
  has_many :board_comment, lambda{ order("comment_no asc") }


  # モデル名 model name
  MY_ATT_DIR="boards"
  # 添付ファイル形式許可リスト Attachment file format permission list
  # pdf,png,xls,xlsx,doc,docx,ppt,pptx
  FILE_EXTENSIONS = {:document=>%w(pdf),:image=>%w(jpg jpeg png),:msoffice=>%w(xls xlsx doc docx ppt pptx)}
  # FILE_EXTENSIONS = {:document=>%w(pdf),:image=>%w(png),:msoffice=>%w(xls xlsx doc docx ppt pptx)}
  FILE_LOCATION="system/" + MY_ATT_DIR
  #
  #===コールバック callback
  after_create :set_after_update
  after_update :set_after_update

  #
  #===入力画面フォームの生成 Generation of input screen form
  def self.set_input_form(key)
    board_category = BoardCategory.getdatalist({:order=>:desp_index})
    form = Common::CommonClass.new(key)
    form.setparams("important_flg",{"title"=>self.human_attribute_name(:important_flg),"type"=>"check_one",'size'=>"1","maxlength"=>"1","inputFlg"=>1,"essFlg"=>0,"align"=>"C"})
    form.setparams('view_s_dt',{'title'=>self.human_attribute_name(:view_s_dt),'type'=>'textDT','size'=>'20','maxlength'=>'16','inputFlg'=>1,'essFlg'=>1,'align'=>'C'})
    form.setparams("view_e_infin",{"title"=>self.human_attribute_name(:view_e_infin),"type"=>"check_one",'size'=>"1","maxlength"=>"1","inputFlg"=>1,"essFlg"=>0,"align"=>"C"})
    form.setparams('view_e_dt',{'title'=>self.human_attribute_name(:view_e_dt),'type'=>'textDT','size'=>'20','maxlength'=>'16','inputFlg'=>1,'essFlg'=>0,'align'=>'C'})
    form.setparams("board_group_id",{"title"=>"掲示公開グループID","type"=>"hidden",'size'=>"1","maxlength"=>"1","inputFlg"=>0,"essFlg"=>1,"align"=>"L"})
    form.setparams("board_category_id",{"title"=>self.human_attribute_name(:board_category_id),"type"=>"select",'size'=>"8","maxlength"=>"8","inputFlg"=>1,"essFlg"=>1,"align"=>"L",
      "list"=>board_category})
    form.setparams('subject',{'title'=>self.human_attribute_name(:subject),'type'=>'textJ','size'=>'60','maxlength'=>'64','inputFlg'=>1,'essFlg'=>1,'align'=>'L'})
    form.setparams('body1',{'title'=>self.human_attribute_name(:body1),'type'=>'textAria','rows'=>'3','cols'=>'80','inputFlg'=>1,'essFlg'=>0,'align'=>'L'})
    form.setparams('file_name',{'title'=>self.human_attribute_name(:file_name),'type'=>'file','size'=>'40','maxlength'=>'254','inputFlg'=>1,'essFlg'=>0,'align'=>'L',
        'img_dir'=>FILE_LOCATION,'img_key'=>'id','ext_ck'=>FILE_EXTENSIONS.values.flatten.join(","),"viewform"=>"file","multiple"=>1})
    form.setparams('file_name2',{'title'=>self.human_attribute_name(:file_name),'type'=>'file','size'=>'40','maxlength'=>'254','inputFlg'=>1,'essFlg'=>0,'align'=>'L',
        'img_dir'=>FILE_LOCATION,'img_key'=>'id','ext_ck'=>FILE_EXTENSIONS.values.flatten.join(","),"viewform"=>"file","multiple"=>1})
    form.setparams('file_name3',{'title'=>self.human_attribute_name(:file_name),'type'=>'file','size'=>'40','maxlength'=>'254','inputFlg'=>1,'essFlg'=>0,'align'=>'L',
        'img_dir'=>FILE_LOCATION,'img_key'=>'id','ext_ck'=>FILE_EXTENSIONS.values.flatten.join(","),"viewform"=>"file","multiple"=>1})
    form.setparams('file_name4',{'title'=>self.human_attribute_name(:file_name),'type'=>'file','size'=>'40','maxlength'=>'254','inputFlg'=>1,'essFlg'=>0,'align'=>'L',
        'img_dir'=>FILE_LOCATION,'img_key'=>'id','ext_ck'=>FILE_EXTENSIONS.values.flatten.join(","),"viewform"=>"file","multiple"=>1})
    form.setparams('file_name5',{'title'=>self.human_attribute_name(:file_name),'type'=>'file','size'=>'40','maxlength'=>'254','inputFlg'=>1,'essFlg'=>0,'align'=>'L',
        'img_dir'=>FILE_LOCATION,'img_key'=>'id','ext_ck'=>FILE_EXTENSIONS.values.flatten.join(","),"viewform"=>"file","multiple"=>1})
    form.setparams('body2',{'title'=>self.human_attribute_name(:body2),'type'=>'textAria','rows'=>'3','cols'=>'80','inputFlg'=>1,'essFlg'=>0,'align'=>'L'})
    return form
  end
  #\

  #===更新画面フォームの生成 Generate update screen form
  def self.set_edit_form(key)
    return self.set_input_form(key)
  end
  #
  #===一覧画面フォームの生成 Generate list screen form
  def self.set_list_form(key)
    form = self.set_input_form(key)
    skeys = ["important_flg","view_s_dt","view_e_infin","view_e_dt","board_category_id","subject"]
    # skeys = ["important_flg","board_group_id","view_s_dt","view_e_infin","view_e_dt","board_category_id","subject"]
    pkeys = Marshal.load(Marshal.dump(form.getparamkey))
    pkeys.each {|pkey|
      form.unsetparams(pkey) unless skeys.include?(pkey)
    }

    form.set_all_param("inputFlg",0)
    form.set_all_param("essFlg",0)
    form.setparams('id',{'title'=>'ID','type'=>'hidden','size'=>'20','maxlength'=>'16','inputFlg'=>0,'essFlg'=>0,'align'=>'R','noserch'=>"1"})
    form.set_index('id',0)
    form.setparam('important_flg','type','select')
    form.setparam('important_flg','list',[["★","1"],["無",""]])
    form.setparam('view_e_infin','type','select')
    form.setparam('view_e_infin','list',[["無期限","1"],["期限有",""]])
    form.setparam('subject','size',20)
    form.setparam('subject','link',{:action=>:edit,:id=>'id'})
    %w[target_count confirmation_count comment_count].each{|addkey|
      form.setparams(addkey,{'title'=>addkey,'type'=>'hidden','size'=>'20','maxlength'=>'16','inputFlg'=>0,'essFlg'=>0,'align'=>'R','noserch'=>"1"})
    }
    return form
  end
  #
  #===重要アイコン取得 Get important icon
  # 「★」 or 「」
  def important_str
    return (self[:important_flg] == 1 ? "★" : "")
  end
  
  #===掲示期間を返す Return the posting period
  def view_tarm_str(format_str)
    ret = "#{self[:view_s_dt].strftime(format_str)}"
    ret << "～"
    if self[:view_e_infin] == 1
      ret << "無期限"
    else
      ret << "#{self[:view_e_dt].try(:strftime,format_str)}"
    end
    return ret;
  end
  #
  #===掲示期間内か真偽値を返す Returns a true/false value if it is within the posting period
  def in_view_tarm?(t_time=Time.now)
    return false if self[:view_s_dt].blank? || (self[:view_e_infin].blank? && self[:view_e_dt].blank?)
    gte_s_dt = self[:view_s_dt] <= t_time
    lte_e_dt = self[:view_e_infin] || self[:view_e_dt] >= t_time
    return gte_s_dt && lte_e_dt
  end

  #===既読？ Already read?
  def read?(user_id)
    bt = self.board_target
    return false if bt.blank?
    return bt.find_by(:user_id=>user_id) && bt.find_by(:user_id=>user_id).confirmation_m_at.present?
    false
  end
  
  
  #===実ファイルへのパスを返す returns the path to the actual file
  def get_pdf_path
    path = File.join(IMG_DIR,FILE_LOCATION,"file_name_#{self[:id]}.pdf")
    # path = File.join(IMG_DIR,MY_ATT_DIR,"file_name_#{self[:id]}.pdf")
    return path if File.exist?(path)
    return nil
  end
  
  #
  #===実ファイルへのパスを返す returns the path to the actual file
  def get_file_path(*attribute_keys)
    loop_keys = attribute_keys.empty? ? Board.file_attributes : attribute_keys.map(&:to_sym)
    return loop_keys.map{|key|
      path = File.join(IMG_DIR,FILE_LOCATION,"#{key}_#{self[:id]}.#{self.get_file_extention(key)}")  
      ret_path = File.exist?(path) ? path : nil
      [key,ret_path]
    }.to_h
  end

  #===実ファイルへのパスを返す returns the path to the actual file
  # def get_file_path
  #   path = File.join(IMG_DIR,MY_ATT_DIR,"file_name_#{self[:id]}.#{self.get_file_extention}")
  #   return path if File.exist?(path)
  #   return nil
  # end
  #
  #===画像ファイルへのパスを返す returns the path to the image file
  def imgs(key=nil)
    file_path = File.join(IMG_DIR,FILE_LOCATION,"#{self[:id]}")
    # file_path = File.join(IMG_DIR,MY_ATT_DIR,"#{self[:id]}")
    if Dir.exist?(file_path)
      if key
        first_num = Board.get_first_number(key)
        return [] if first_num.blank?
        return Dir.glob("#{file_path}/#{first_num}*.png").map{|path| path.sub(/^public/,"")}
      else
        return Dir.glob("#{file_path}/*.png").map{|path| path.sub(/^public/,"")}
      end
    else
      return []
    end
  end
  #
  #===登録、更新の後処理 Post-processing of registration and updates
  def set_after_update(target_users=[])
    #PDFファイルの画像化 Imaging PDF files
    set_images
    #掲示対象者設定 Post target audience settings
    board_targets = BoardTarget.where(:board_id=>self.id)&.pluck(:login_id) || []
    dif_targets = (target_users-board_targets) + (board_targets-target_users)
    if target_users.present? && dif_targets.present?
      set_targets(target_users)
    end
  end

  def set_images()
    self.get_file_path.each do |key,path|
      next unless path
      next unless self.get_file_extention(key).upcase=='PDF'
      img_file_first_number = Board.get_first_number(key)
      set_image(path,img_file_first_number)
    end
  end


  #
  #===PDFファイルの画像化 Imaging PDF files
  def set_image(path,pre_number=nil)
    # 画像ファイル名 0000から始まる4桁の数字 Image file name 4-digit number starting from 0000
    # pre_number: 先頭の一桁の数字を指定 pre_number: Specify the first digit
    if path.present? && File.exist?(path)
      img_path = File.join(IMG_DIR,FILE_LOCATION,"#{self[:id]}")
      do_make_image = false
      if Dir.exist?(img_path)
        images = Dir.glob("#{img_path}/#{pre_number}*.png")
        if images.blank?
          do_make_image = true
        else
          images.each{|image|
            do_make_image = true || (File.ctime(path) > File.ctime(image)) #判定：PDFファイル作成日＞画像ファイル作成日 Judgment: PDF file creation date > image file creation date
            break if do_make_image
          }
          images.each{|image| File.unlink(image)} if do_make_image
        end
      else
        Dir::mkdir(img_path,0755)
        do_make_image = true
      end

      if do_make_image
        require 'rmagick'
        first_number = pre_number.to_i
        images = Magick::Image.read("#{path}")
        images.each_with_index{|image,index|
          file_name = "#{img_path}/#{first_number}#{format("%03d",index)}.png"
          image.write(file_name)
        } unless images.blank?
      end
    end
  end
  #
  #===対象者設定 Target audience settings
  def set_targets(target_users=[])
    #一旦全対象者を論理削除 Logically delete all targets once
    BoardTarget.delete_all(self[:updated_uid],{:board_id=>self[:id]})
    #基準日を取得 Get base date
    if self[:view_s_dt] > Time.now()
      applicable = Applicable.get_applicable(2,self[:view_s_dt])
    else
      applicable = Applicable.get_applicable(2)
    end
    #カウントを初期化 Initialize count
    target_count=0 ; confirmation_count=0
    #対象者設定 Target audience settings
    if target_users.present?
      condition = ["users.login_id in (?)",target_users]
    elsif self.board_group.can_mod_group_type?
      bgws = self.board_group.board_group_woker
      login_ids = bgws.map{|bgw|bgw[:login_id]} unless bgws.blank?
      condition = ["users.login_id in (?)  and (wokers.applicable is null or wokers.applicable = ?)",login_ids,applicable]
    else
      case self.board_group[:group_type]
      when "all" ; condition = ["(wokers.applicable is null or wokers.applicable = ?)",applicable]
      when "10"  ; condition = ["wokers.branch_cd in ('1','2') and (wokers.applicable is null or wokers.applicable = ?)",applicable]
      when "20"  ; condition = ["wokers.branch_cd in ('3','4') and (wokers.applicable is null or wokers.applicable = ?)",applicable]
      else       ; condition = ["wokers.branch_cd = ? and (wokers.applicable is null or wokers.applicable = ?)",self.board_group[:group_type],applicable]
      end
    end
    t_users = User.includes(:woker).references(:woker).where(condition)
    t_users.each{|user|
      woker = user.woker_for
      b_target = BoardTarget.unscoped.find_by({:board_id=>self[:id],:login_id=>user[:login_id]})
      if b_target.blank?
        b_target = BoardTarget.new({
          :board_id=>self[:id],
          :login_id=>user[:login_id],
          :created_at=>self[:updated_at],
          :created_uid=>self[:updated_uid],
        }) 
      end
      b_target[:user_id] = user[:id]
      b_target[:branche_cd] = (woker.blank? ? nil :  woker[:branch_cd])
      b_target[:updated_at] = self[:updated_at]
      b_target[:updated_uid] = self[:updated_uid]
      b_target[:deleted_at] = nil
      b_target.save!
      target_count += 1
      confirmation_count +=1 if b_target[:confirmation_m_at].present?
    }unless t_users.blank?
    self[:target_count] = target_count
    self[:confirmation_count] = confirmation_count
    self.save!
  end
  #
  #===再カウント Recount
  def recount_all
    recount()
    recount("comment_count")
  end
  def recount(key="")
    case key
    when "comment_count" ; self[:comment_count] = self.board_comment.size
    else
      board_target =  self.board_target
      self[:target_count] = board_target.size
      self[:confirmation_count] = board_target.where("not confirmation_m_at is null").size
    end
  end

  #===掲示コメントを追加 Add post comment
  def add_comment(user_id,comment_text)
    Board.transaction do
      user = User.find(user_id)
      # Board
      self.recount_all
      self.comment_count +=1
      self.updated_at = Time.now
      self.updated_uid= user.login_id
      self.save
      # BoardComment
      @board_comment = self.board_comment.new
      comment_nums = BoardComment.unscope(:where).where(:board_id=>self.id)&.maximum(:comment_no)
      @board_comment.comment_no = comment_nums ? comment_nums+1:1 
      @board_comment.user_id = user.id
      @board_comment.comment = comment_text
      @board_comment.created_at = Time.now
      @board_comment.created_uid = user.login_id
      @board_comment.updated_at = Time.now
      @board_comment.updated_uid = user.login_id
      @board_comment.save
      # BoardTarget
      self.board_target.update_all(:confirmation_s_at=>nil,:updated_uid=>user.login_id)
    rescue => e
      raise e
    end  

  end

  # スコープ scope
  #===掲示期間のBoardを返す Return the board for the posting period
  scope :find_board_in_view_tarm, -> {
    now = Time.now
    where("view_s_dt <= ?", now).merge(
      Board.where("view_e_dt >= ?",now).or(Board.where(:view_e_infin=>1,))
    ).order(:id)
  }
  #=== 添付ファイルのファイル拡張子を返す Return file extension of attachment
  def get_file_extention(attribute_key)
    key = attribute_key.to_sym
    return nil if self[key].blank?
    return self[key][self[key].rindex(".")+1..-1]
  end

  #=== 添付ファイルの有無を返す Returns whether there is an attachment
  def has_file?
    Board.file_attributes.map{|key| self[key]}.any?(&:present?)
  end

  private

  def self.file_attributes()
    return  self.attribute_names.filter{|nm| nm.include?("file_name")}.map(&:to_sym)
  end

  # 画像化時のpngファイル名の1桁目の数字を取得 Get the first digit of the png file name when converting an image
  def self.get_first_number(key)
    return 0 if key==:file_name
    return 1 if key==:file_name2
    return 2 if key==:file_name3
    return 3 if key==:file_name4
    return 4 if key==:file_name5
    return nil
  end




end
