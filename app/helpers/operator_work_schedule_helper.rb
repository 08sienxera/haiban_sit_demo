module OperatorWorkScheduleHelper
  # 連結文字列 concatenated string
  JoinChar = "、"
  # 配列をJoinCharで連結し返す The arrays are concatenated using JoinChar and returned.
  def ary_to_joined_comma(ary)
    return "" if ary.length==0
    ret = (ary|[]).join(JoinChar)
    ret = ret[1..] if ret.start_with?(JoinChar)
    return ret
  end
end