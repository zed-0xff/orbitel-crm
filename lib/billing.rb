class Billing
  class << self
    attr_reader :klass
    def klass= klass
      @klass = klass.is_a?(Symbol) ?  "Billing::#{klass.to_s.camelize}".constantize : klass
    end
    def method_missing mname, *args
      if @klass
        @klass.send(mname,*args)
      else
        raise "Billing class not set"
      end
    end
  end
end
