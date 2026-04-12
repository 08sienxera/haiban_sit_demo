namespace :testuser do
    desc "テスト作業員(001)の掲示閲覧履歴をリセットします"
    task :reset_confirm_board=>:environment do 
        UserId = 2
        board_targets = BoardTarget.where(user_id:UserId)
        return if board_targets.blank?
        board_targets.update_all(confirmation_m_at:nil)
    end
end
