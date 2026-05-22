class Excel::ExcelFormatBuilder
  def initialize(workbook,style={})
    @workbook = workbook
    @style = style
    @is_old = false
    @format_object = nil
  end

  #-- 操作 | operation
  def get_style()
    return @style
  end
  def get_format()
    if @is_old
      @format_object = nil
      @is_old = false
    end
    @format_object ||= @workbook.add_format(**@style)
    @format_object
  end
  def workbook()
    return @workbook
  end
  def copy()
    return Excel::ExcelFormatBuilder.new(@workbook,@style.dup)
  end
  def cancel(key)
    @style.delete(key)
    @is_old = true
    return self
  end
  def merge(*excel_format_builder)
    excel_format_builder.each{|obj| add(obj.get_style)}
    @is_old = true
    return self
  end


  #-- 書式設定 | Formatting
  def size(size)
    add({:size=>size})
    self
  end
  def color(color)
    add({:color=>color})
    self
  end
  def bg_color(bg_color)
    add({:bg_color=>bg_color})
    self
  end
  def align(value)
    add({:align=>value})
    self
  end
  def valign(value)
    value = "v"+value unless value[0]!="v"
    add({:valign=>value})
    self
  end
  def vcenter()
    add({:valign=>"vcenter"})
    self
  end
  def num_format(format)
    add({:num_format=>format})
    self
  end
  def bold(weight)
    add({:bold=>weight})
    self
  end
  def font(font_name)
    add({:font=>font_name})
    self
  end
  def font_g()
    add({:font=>'ＭＳ Ｐゴシック'})
    self
  end
  def font_m()
    add({:font=>'明朝'})
    self
  end
  def wrap(bool)
    add({:text_wrap=>bool ? 1 : 0})
    self
  end
  def borders(borders=[0,0,0,0])
    [:top,:right,:bottom,:left].each.with_index do |target,index|
      border_width = borders[index]
      if border_width>0
        add({target=>border_width})
      else
        cancel(target)
      end
    end
    self
  end
  def border_top(border_width)
    add({:top=>border_width})
    self
  end
  def border_right(border_width)
    add({:right=>border_width})
    self
  end
  def border_bottom(border_width)
    add({:bottom=>border_width})
    self
  end
  def border_left(border_width)
    add({:left=>border_width})
    self
  end




  private  
  def add(hash)
    @is_old = true
    hash.each do |key,value|
      @style[key] = value
    end
  end


end