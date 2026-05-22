# coding: utf-8
#--
#***************************************************************************
#*     ｼｽﾃﾑ名    ：
#*     ｻﾌﾞｼｽﾃﾑ名 ：    一時データ等削除バッチ
#*     ｺﾒﾝﾄ      ：    
#*                     (x) 1日前のログファイルを削除(本番以外)
#*     作成      ：    2016/07/30 SEIKO
#*     変更	：
#***************************************************************************
#++

#=一時データ等削除バッチ Temporary data deletion batch
class Batche::CleanUp < Batche::BatcheCommon
  #===実行 execution
  def self.do
    @ret = []
    @log = self.logger()
    log_info("batch start #{self.name}----")
    @myname = self.name.gsub("Batche::","")
    # (1) 2日前のセッションデータを削除
    # key_day = (Date.today - 2)
    # Session.destroy_all(["updated_at < ?",key_day])
    # @@log.info("Session.destroy_all([\"updated_at < ?\",#{key_day}])")
    #(2) 1日前のExcelファイルを削除
    # (1) Delete session data from 2 days ago
    # key_day = (Date.today - 2)
    # Session.destroy_all(["updated_at < ?",key_day])
    # @@log.info("Session.destroy_all([\"updated_at < ?\",#{key_day}])")
    # (2) Delete Excel file from 1 day ago
    key_day = (Date.today - 1)
    tfiles = Dir.glob("#{FILE_OUT_DIR}/*.xls")
    tfiles.each{|tfile|
      File.unlink(tfile)  if File.ctime(tfile) < key_day
    }unless tfiles.blank?
    log_info("Exl destroy_all([\"updated_at < ?\",#{key_day}])")
    #(3) 1日前のExcelファイルを削除 #(3) Delete the Excel file from the previous day.
    tfiles = Dir.glob("#{PDF_OUT_DIR}/*.pdf")
    tfiles.each{|tfile|
      File.unlink(tfile)  if File.ctime(tfile) < key_day
    }unless tfiles.blank?
    log_info("PDF destroy_all([\"updated_at < ?\",#{key_day}])")
    #(4) 1日前のJobメッセージを削除 #(4) Delete the job message from the previous day.
    DelayedJobMsg.unscoped.where(["created_at < ?",key_day]).destroy_all

    ##(x) 1日前のログファイルを削除(本番以外) Delete log files from the previous day (non-production).
    #unless Rails.env.production?
    #  key_day = (Date.today - 1)
    #  tfiles = Dir.glob("log/*")
    #  tfiles.each{|tfile|
    #    File.unlink(tfile)  if File.mtime(tfile) < key_day
    #  }unless tfiles.blank?
    #  log_info("log/*files.destroy_all([\"updated_at < ?\",#{key_day}])")
    #end
    #  rescue
    #    @@log.error($!)
    #    @@log.error("---backtrace---")
    #    @@log.error($!.backtrace.join("\n"))
    #    @@retmsg << "error"
    #  end
    log_info("batch End #{self.name}----")
    return @ret
  end


end
