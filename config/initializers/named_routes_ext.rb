require 'action_controller/polymorphic_routes'
module ActionController
  module PolymorphicRoutes
    alias :build_named_route_call_orig :build_named_route_call
    def build_named_route_call records, *args
      named_route_call = build_named_route_call_orig(records, *args)
      if !self.respond_to?(named_route_call) && records.is_a?(ActiveRecord::Base)
        klass = records.class
        while (klass = klass.superclass) && (klass != ActiveRecord::Base)
          sti_named_route_call = build_named_route_call_orig(klass, *args)
          if self.respond_to?(sti_named_route_call)
            named_route_call = sti_named_route_call 
            break
          end
        end
      end
      named_route_call
    end
  end
end
