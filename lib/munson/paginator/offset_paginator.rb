module Munson
  module Paginator
    class OffsetPaginator
      def initialize(options={})
        @max_limit = options[:max]
        @default_limit = options[:default]
      end

      def set(opts={})
        limit(opts[:limit]) if opts[:limit]
        offset(opts[:offset]) if opts[:offset]
      end

      def to_params
        {
          page: {
            limit: @limit || @default_limit || 10,
            offset: @offset
          }.select { |_, value| !value.nil? }
        }
      end

      private

      # Set limit of resources per page
      #
      # @param [Fixnum] num number of resources per page
      def limit(num)
        if @max_limit && num > @max_limit
          @limit = @max_limit
        else
          @limit = num
        end
      end

      # Set offset
      #
      # @param [Fixnum] num pages to offset
      def offset(num)
        @offset = num
      end
    end
  end
end
Munson.register_paginator(:offset, Munson::Paginator::OffsetPaginator)
