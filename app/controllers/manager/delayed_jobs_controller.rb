class Manager::DelayedJobsController < Manager::HomeController
  # 遅延処理実行状況を返す Return the status of the delayed processing
  def show
    job = DelayedJob.find_by_queue(params[:id])
    msg = DelayedJobMsg.find_by_queue(params[:id])
    if job.blank?
      if msg.present?
        ret={:msg=>msg[:msg].gsub("\n","<br />"),:sts=>303}
        msg.destroy
      else
        ret={:msg=>"完了しました。",:sts=>404}
      end
    elsif job[:last_error].present?
      ret={:msg=>"実行エラー<br />#{job[:last_error].gsub("\n","<br />")}",:sts=>500}
    elsif msg.present?
        ret={:msg=>msg[:msg].gsub("\n","<br />"),:sts=>303}
    else
      ret={:msg=>"実行中",:sts=>303}
    end
    render :json => ret.to_json, :status => 200
  end
  private
end
