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
      def has_many(*);end;
      def has_one(*);end;
      def belongs_to(*);end;
    end
  end
end
