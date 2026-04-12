# coding: utf-8
class BoardComment < ApplicationRecord
  extend Common::Func
  default_scope {where(:deleted_at => nil)}
  belongs_to :board
  belongs_to :user

  #=== コメントを更新
  def update_comment(comment_text,login_uid)
      self.update!(:comment=>comment_text,:updated_at=>Time.now,:updated_uid=>login_uid);
  end
  #=== コメントを論理削除
  def delete_comment(login_uid)
    self.update!(:deleted_at=>Time.now,:deleted_uid=>login_uid);
  end

  #=== view用の投稿者情報文字列を返す
  # 例："山田太郎／2024/06/01 10:24"
  def comment_title_str()
    return "#{User.find(self.user_id).name}／#{self.created_at.strftime("%Y/%m/%d %H:%M")}"
  end




end
