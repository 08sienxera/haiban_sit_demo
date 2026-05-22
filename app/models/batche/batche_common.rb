# encoding: utf-8
#--
#***************************************************************************
#*     ｼｽﾃﾑ名    ：    
#*     ｻﾌﾞｼｽﾃﾑ名 ：    
#*     ｺﾒﾝﾄ      ：   バッチ共通クラス
#*     作成      ：    2013/01/10 SEIKO N.Ooshige
#*     変更	：
#***************************************************************************
#++
#== バッチ共通クラス Batch common class
class Batche::BatcheCommon
  protected
  #
  #===初期化 Initialization
  def self.logger()
    log_file = "log/#{self.name.gsub("Batche::","")}.log"
    log = Logger.new(log_file, 'daily')
    #--
    #log.level = Rails.env.production? ? Logger::WARN : Logger::INFO
    #++
    log.level = Logger::INFO
    log.formatter = Logger::Formatter.new
    log.datetime_format = "%Y-%m-%d %H:%M:%S"
    return log
  end
  #
  #===debugログ debug log
  def self.log_debug(str)
    @log.debug(str)
    @ret << str
  end
  #
  #===infoログ info log
  def self.log_info(str)
    @log.info(str)
    @ret << str
  end
  #
  #===エラーログ error log
  def self.log_error(str)
    @log.error(str)
    @ret << str
  end
end
