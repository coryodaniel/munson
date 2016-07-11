module Munson
  module Paginator
    class PagedPaginator
      def initialize(options={})
        @max_size = options[:max]
        @default_size = options[:default]
      end

      def set(opts={})
        number(opts[:number]) if opts[:number]
        size(opts[:size]) if opts[:size]
      end

      def to_params
        {
          page: {
            size: @size || @default_size || 10,
            number: @number
          }.select { |_, value| !value.nil? }
        }
      end

      private

      # Set number of resources per page
      #
      # @param [Fixnum] num number of resources per page
      def size(num)
        if @max_size && num > @max_size
          @size = @max_size
        else
          @size = num
        end
      end

      # Set page number
      #
      # @param [Fixnum] num page number
      def number(num)
        @number = num
      end

    end
  end
end

Munson.register_paginator(:paged, Munson::Paginator::PagedPaginator)
