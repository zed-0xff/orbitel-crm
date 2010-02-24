class Billing
  class << self
    attr_reader :klass

    def klass= klass
      @klass = [Symbol,String].include?(klass.class) ? "Billing::#{klass.to_s.camelize}".constantize : klass
    end

    def configure!
      if !@klass && defined?(configatron) && !configatron.billing.klass.nil?
        self.klass = configatron.billing.klass
        configatron.billing.to_hash.each do |k,v|
          self.send("#{k}=",v) if self.respond_to?("#{k}=")
        end
      end
    end

    def inspect
      configure!
      @klass || 'Billing'
    end

    def method_missing mname, *args
      if self == Billing
        configure!
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
