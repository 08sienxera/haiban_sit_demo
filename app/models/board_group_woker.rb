#= 掲示対象者
class BoardGroupWoker < ApplicationRecord
    extend Common::Func
    default_scope {where(:deleted_at => nil)}
    belongs_to :board_group
    belongs_to :user, primary_key: :login_id, foreign_key: :login_id
end
