# coding: utf-8
#***************************************************************************
#*     ｼｽﾃﾑ名    ：    西鉄旅行　
#*     ｻﾌﾞｼｽﾃﾑ名 ：    Jobチェックバッチ
#*     ｺﾒﾝﾄ      ：
#*     作成      ：    2024/10/10 SEIKO
#*     変更	：
#***************************************************************************
class Batche::CkJob < Batche::BatcheCommon

  def self.do
    # (1)エラーが発生していたら通知し、該当JOBを削除する
    # （該当JOBをリトライするのでいつまでたっても終わらない）
    # (2)実行予定時間より１時間経過したJOBがあれば通知する
    # （JOBのワーカーが止まっている場合を検知したい）
    # バッチ作成し、crontabで１時間毎に実行してもらいたい。
    # (1) Notify if an error occurs and delete the relevant job.
    # (This will never finish because it will retry the job.)
    # (2) Notify if there is a job that has been running for more than one hour beyond its scheduled execution time.
    # (We want to detect when a job worker has stopped.)
    # Create a batch file and have it run every hour using crontab.
    ret = []
    @@log = self.logger()
    @@log.info("batch start #{self.name}----")
    @@myname = self.name.gsub("Batche::","")
    #DelayedJobでエラーが発生していたら通知し、該当JOBを削除する If an error occurs in DelayedJob, notify the system and delete the job in question.
    tbl = DelayedJob.where("last_error<>''")
    unless tbl.blank?
      tbl.each{|lin|
        body = ""
        body << "id:#{lin[:id]}\r\n"
        body << "run_at:#{lin[:run_at]}\r\n"
        body << "attempts:#{lin[:attempts]}\r\n"
        body << "failed_at:#{lin[:failed_at]}\r\n"
        body << lin[:last_error]
        @@log.info("-"*40)
        @@log.info(body)
        ActionMailer::Base.mail(
          :from => SYS_MAIL_FROM,
          :to => EXCEPTION_NOTIFIER_MAIL_CONFIG[:exception_recipients],
          :subject => "[HaibanSitDemo(#{Rails.env.slice(0,1)})]Jobエラー",
          :body => body,
        ).deliver_now
        ret << "run_at:#{lin[:run_at]}"
        lin.destroy
      }
    end
    #DelayedJobで実行予定時間より１時間経過したJOBがあれば通知する DelayedJob will notify if there are any jobs that have been running for more than one hour longer than their scheduled execution time.
    tbl = DelayedJob.where("run_at<'#{1.hour.ago}'")
    unless tbl.blank?
      body = ""
      tbl.each{|lin|
        tmp_str = "id:#{lin[:id]} / run_at:#{lin[:run_at].strftime("%Y/%m/%d %H:%M")} / created_at:#{lin[:created_at].strftime("%Y/%m/%d %H:%M")}"
        body << "#{tmp_str}\r\n"
        ret << tmp_str
      }
      @@log.info("-"*40)
      @@log.info(body)
      ActionMailer::Base.mail(
        :from => SYS_MAIL_FROM,
        :to => EXCEPTION_NOTIFIER_MAIL_CONFIG[:exception_recipients],
        :subject => "[HaibanSitDemo(#{Rails.env.slice(0,1)})]Job実行遅延",
        :body => body,
      ).deliver_now
    end
#    rescue
#      @@log.error($!)
#      @@log.error("---backtrace---")
#      @@log.error($!.backtrace.join("\n"))
#      @@retmsg << "error"
#    end
    @@log.info("batch End #{self.name}----")
    
    return ret
  end
end
