# coding: utf-8
class BoardTarget < ApplicationRecord
  extend Common::Func
  default_scope {where(:deleted_at => nil)}
  belongs_to :board
  belongs_to :user

  #
  #===コールバック
  after_update do
    self.board.recount_all
  end

  #
  #===閲覧検索フォームの生成
  def self.set_serch_form(key)
    #[AuthFlg].each{|list| list.delete(SERCH_ALL) if list.index(SERCH_ALL).present? }

    form = Common::CommonClass.new(key)
    branch_list = Branche.getdatalist({:key=>:cd,:text=>:name,:where=>{:applicable=>Applicable.get_applicable(1)},:order=>:desp_index,:all=>":all"})
    form.setparams("login_id",{"title"=>self.human_attribute_name(:login_id),"type"=>"textA",'size'=>"20","maxlength"=>"16","inputFlg"=>1,"essFlg"=>0,"align"=>"L",
      'serch_field'=>"board_targets.login_id"})
    form.setparams("branch_cd",{"title"=>Woker.human_attribute_name(:branch_cd),"type"=>"select",'size'=>"9","maxlength"=>"8","inputFlg"=>1,"essFlg"=>0,"align"=>"L","list"=>branch_list,
      'serch_field'=>"board_targets.branch_cd"})
    form.setparams("name",{"title"=>self.human_attribute_name(:name),"type"=>"textJ",'size'=>"20","maxlength"=>"32","inputFlg"=>1,"essFlg"=>0,"align"=>"L",
      'serch_field'=>"users.name"})
    form.setparams("confirmation_m_at",{"title"=>"状況","type"=>"select",'size'=>"9","maxlength"=>"8","inputFlg"=>1,"essFlg"=>0,"align"=>"L",
      "list"=>[["未読","0"],["既読","1"]],'serch_field'=>"case when board_targets.confirmation_m_at is null then '0' else '1' end"})
    s_form = Common::CommonClass.new(key)
    s_form.set_serch_params(form)
    return s_form
  end

  #===本文確認を確認済みに更新
  def confirm_m(login_id)
    if self.login_id == login_id
      self.update!(:confirmation_m_at=>Time.now,:updated_uid=>login_id,:updated_at=>Time.now)      
      self.board.recount_all
      self.board.save
    end
  end
  #===コメント確認を確認済みに更新
  def confirm_s(login_id)
    if self.login_id == login_id
      self.update!(:confirmation_s_at=>Time.now,:updated_uid=>login_id,:updated_at=>Time.now)      
      self.board.recount("comment_count")
      self.board.save!
    end
  end


  scope :unread, ->(user_id){BoardTarget.where(:user_id=>user_id,:confirmation_m_at=>nil)}
end
