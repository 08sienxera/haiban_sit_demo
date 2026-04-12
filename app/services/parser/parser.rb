class Parser::Parser
  def initialize(*args)
    @resource = args
  end

  def parse()
    raise NotImplementedError,"parse メソッドはサブクラスで実装してください"
  end

end