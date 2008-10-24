class Module
  def fattr_nn(name,&b)
    fattr(name) do 
      str = respond_to?(:h) ? h.inspect : ""
      instance_eval(&b).tap { |x| raise "#{name} returning #{x.class} #{str} " unless x }
    end
    fattr("#{name}_cbn") do
      instance_eval(&b)
    end
  end      
end