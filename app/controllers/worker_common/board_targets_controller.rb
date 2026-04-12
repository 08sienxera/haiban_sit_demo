class WorkerCommon::BoardTargetsController < ApplicationController

  # 本文確認済み更新
  def update
    if board_target = BoardTarget.find(params[:id])
      if board_target.user_id != get_uval(:id)
        ret = {:sts=>500,:msg=>"他の作業を実行しています。しばらくお待ちいただいた後に再度実行してください。"}
        head :bad_request
        return
      end
      board_target.confirm_m(get_uval(:login_id))
      head :ok
    else
      head :bad_request
    end
  end

end
