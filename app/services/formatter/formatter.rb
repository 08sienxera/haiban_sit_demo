class Formatter::Formatter

  def initialize()
    @formatted_data = nil
  end

  def fetch_data()
    @formatted_data || raise(NotImplementedError,"フォーマット済みデータが未生成です")
  end

  def convert()
    raise NotImplementedError,"convert メソッドはサブクラスで実装してください"
  end

  def store_data(data,clone:false)
    if :clone
      @formatted_data = Marshal.load(Marshal.dump(data))
    else
      @formatted_data = data
    end

  end

end