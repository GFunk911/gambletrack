class Object
  def page_title
    desc
  end
end

class Object
  def ar_desc
    respond_to?(:desc) ? desc : self
  end
end

class Object
  def pretty
    self
  end
end

class Object
  def send_catch(sym,*args,&b)
    send(sym,*args,&b)
  rescue => exp
    dbg exp.inspect
    return nil
  end
end

class Object
  def tap_inspect(prefix=nil)
    puts((prefix ? "#{prefix} " : "") + inspect)
    self
  end
  def tap_to_s(prefix=nil)
    puts((prefix ? "#{prefix} " : "") + to_s)
    self
  end
end