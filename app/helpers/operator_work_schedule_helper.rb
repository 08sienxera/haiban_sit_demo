module OperatorWorkScheduleHelper
  # 連結文字列
  JoinChar = "、"
  # 配列をJoinCharで連結し返す
  def ary_to_joined_comma(ary)
    return "" if ary.length==0
    ret = (ary|[]).join(JoinChar)
    ret = ret[1..] if ret.start_with?(JoinChar)
    return ret
  end
end