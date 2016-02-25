require 'json'

require 'active_support/concern'
require "active_support/inflector"
require "active_support/core_ext/hash"

require 'faraday'
require 'faraday_middleware'

require "munson/version"

require "munson/middleware/encode_json_api"
require "munson/middleware/json_parser"

require 'munson/collection'
require 'munson/paginator'
require 'munson/response_mapper'
require 'munson/query_builder'
require 'munson/connection'
require 'munson/agent'
require 'munson/resource'

module Munson
  @registered_types = {}
  class << self
    # Configure the default connection.
    #
    # @param [Hash] opts {Munson::Connection} configuration options
    # @param [Proc] block to yield to Faraday::Connection
    # @return [Munson::Connection] the default connection

    # @see https://github.com/lostisland/faraday/blob/master/lib/faraday/connection.rb Faraday::Connection
    # @see Munson::Connection
    def configure(opts={}, &block)
      @default_connection = Munson::Connection.new(opts, &block)
    end

    # The default connection
    #
    # @return [Munson::Connection, nil] the default connection if configured
    def default_connection
      defined?(@default_connection) ? @default_connection : nil
    end

    # Register a JSON Spec resource type to a class
    # This is used in Faraday response middleware to package the JSON into a domain model
    #
    # @example Mapping a type
    #   Munson.register_type("addresses", Address)
    #
    # @param [#to_s] type JSON Spec type
    # @param [Class] klass to map to
    def register_type(type, klass)
      @registered_types[type] = klass
    end

    # Lookup a class by JSON Spec type name
    #
    # @param [#to_s] type JSON Spec type
    # @return [Class] domain model
    def lookup_type(type)
      @registered_types[type]
    end

    # @private
    def flush_types!
      @registered_types = {}
    end
  end
end
