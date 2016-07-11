module Munson
  module Resource
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def munson
        return @munson if @munson
        @munson = Munson::Agent.new
        @munson
      end
      
      def register_munson_type(name)
        Munson.register_type(name, self)
        self.munson.type = name
      end

      [:includes, :sort, :filter, :fields, :fetch, :find, :page].each do |method|
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{method}(*args)
            munson.#{method}(*args)
          end
        RUBY
      end
    end
  end
end
