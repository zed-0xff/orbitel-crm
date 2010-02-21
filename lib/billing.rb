class Billing
  class << self
    attr_reader :klass
    def klass= klass
      @klass = klass.is_a?(Symbol) ?  "Billing::#{klass.to_s.camelize}".constantize : klass
    end
    def method_missing mname, *args
      if self == Billing
        if @klass
          @klass.send(mname,*args)
        else
          raise "Billing class not set"
        end
      else
        super
      end
    end
  end
end
