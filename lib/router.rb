class Router
  class << self
    attr_reader :klass

    def klass= klass
      @klass = [Symbol,String].include?(klass.class) ? "Router::#{klass.to_s.camelize}".constantize : klass
    end

    def configure!
      if !@klass && defined?(configatron) && !configatron.router.klass.nil?
        self.klass = configatron.router.klass
        configatron.router.to_hash.each do |k,v|
          @klass.send("#{k}=",v) if @klass.respond_to?("#{k}=")
        end
      end
    end

    def inspect
      configure!
      @klass || 'Router'
    end

    DEFAULT_MENU_ITEMS = [
      {
        :name => 'tcpdump',
        :href => 'tcpdump://{IP}'
      },{
        :name => 'iftop',
        :href => 'iftop://{IP}'
      }
    ]

    # menu items to show in Customer -> [router part]
    # пункты меню, которые показываются в просмотре Абонента -> "Данные роутера"
    # (надо нажать на серенький плюсик)
    def menu_items
      if defined?(configatron) && !configatron.router.menu_items.nil?
        configatron.router.menu_items
      else
        DEFAULT_MENU_ITEMS
      end
    end

    def method_missing mname, *args
      if self == Router
        configure!
        if @klass
          @klass.send(mname,*args)
        else
          raise "Router class not set"
        end
      else
        super
      end
    end
  end
end
