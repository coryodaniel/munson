require 'json'
require 'cgi'
require 'faraday'
require 'faraday_middleware'
require 'bigdecimal'

require "munson/version"
require 'munson/agent'
require 'munson/attribute'
require "munson/client"
require 'munson/collection'
require 'munson/connection'
require 'munson/document'
require 'munson/key_formatter'
require "munson/middleware/encode_json_api"
require "munson/middleware/json_parser"
require 'munson/resource'
require 'munson/response_mapper'
require 'munson/query'

module Munson
  class Error < StandardError; end;
  class UnsupportedSortDirectionError < Munson::Error; end;
  class UnrecognizedKeyFormatter < Munson::Error; end;
  class RelationshipNotIncludedError < Munson::Error; end;
  class RelationshipNotFound < Munson::Error; end;
  class ClientNotSet < Munson::Error; end;
  class RecordNotFound < Munson::Error; end;
  @registered_types = {}

  class << self
    # Transforms a JSONAPI hash into a Munson::Document, Munson::Resource, or arbitrary class
    # @param [Munson::Document,Hash] document to transform
    # @return [Munson::Document,~Munson::Resource]
    def factory(document)
      document = Munson::Document.new(document) if document.is_a?(Hash)
      klass    = Munson.lookup_type(document.type)

      if klass && klass.respond_to?(:munson_initializer)
        klass.munson_initializer(document)
      else
        document
      end
    end

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
    # @param [#to_sym] type JSON Spec type
    # @param [Class] klass to map to
    def register_type(type, klass)
      @registered_types[type.to_sym] = klass
    end

    # Lookup a class by JSON Spec type name
    #
    # @param [#to_sym] type JSON Spec type
    # @return [Class] domain model
    def lookup_type(type)
      @registered_types[type.to_sym]
    end
  end
end
