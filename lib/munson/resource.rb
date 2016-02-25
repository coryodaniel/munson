module Munson
  module Resource
    extend ActiveSupport::Concern

    included do
      def self.munson
        return @munson if @munson
        @munson = Munson::Agent.new
        @munson
      end

      self.munson.path = name.demodulize.tableize
    end

    class_methods do
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
