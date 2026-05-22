# アプリケーション内で色を扱う場合に有効性をチェックしたり、有効なコードに変換を行うモジュール A module that checks the validity of colors when handling them within an application and converts them into valid code.
module ColorConverter extend ActiveSupport::Concern
  require 'color'

  class_methods do
    #=== 引数がシステム内で有効な値を判定する Determines whether the argument has a valid value within the system.
    def is_valid_color?(color)
      begin
        self.new.convert_to_hex(color)
        true
      rescue ArgumentError
        false
      end
    end
  end

  #=== コールバック用 for callback
  def convert_color
    color = self[:color]
    return if color.blank? # カラーが空の場合はスキップ Skip if color is empty
    begin
      converted_color = self.convert_to_hex(color)
      self.color = converted_color # 16進数形式を再代入 Reassign to hexadecimal format
    rescue ArgumentError => e
      raise e,"色の入力値が無効です。"
    end
  end
  
  #=== 引数をシステム内で有効な値に変換する
  # 有効な値：#つきの16進数6桁
  # 変換が可能な引数
  # 　１．#無しの16進数6桁　（例：000000 -> #000000,dcdcdd -> #dcdcdc
  # 　２．'red','green'などの色名 変換できない場合 ArgumentErrorを発生
  # 　３．RGB形式の文字列　（例：'(255,0,0)','255,255,0'  ()の有無は問わない
  #=== Converts arguments to system-valid values
  # Valid values: 6-digit hexadecimal numbers preceded by #
  # Arguments that can be converted
  # 1. 6-digit hexadecimal numbers without # (e.g., 000000 -> #000000,dcdcdd -> #dcdcdc)
  # 2. Color names such as 'red', 'green'. An ArgumentError is generated if conversion is not possible.
  # 3. RGB format strings (e.g., '(255,0,0)', '255,255,0'. The presence or absence of () does not matter.)
  def convert_to_hex(color)
    case color
    when /^#?[0-9a-fA-f]{6}$/ # '(#)16進数  '(#)Hexadecimal
      if color.start_with?("#")
        color.downcase
      else
        "#" + color.downcase
      end
    when /^[a-zA-Z]+$/ #red,green 
      begin
        Color::RGB.by_name(color).html
      rescue KeyError
        raise ArgumentError,"入力が認識できません:#{color}"
      end
    when /^\(?\d{1,3},\s*\d{1,3},\s*\d{1,3}\)?$/
      r,g,b = color.split(",").map(&:to_i)
      Color::RGB.new(r,g,b).html
    else
      raise ArgumentError,"入力が認識できません:#{color}"
    end
  end
  
end