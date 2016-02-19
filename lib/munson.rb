require 'json'

require 'active_support/concern'
require "active_support/inflector"
require "active_support/core_ext/hash"

require 'faraday'
require 'faraday_middleware'

require "munson/version"

require "munson/middleware/encode_json_api"
require "munson/middleware/json_parser"

require 'munson/query_builder'
require 'munson/connection'
require 'munson/agent'
require 'munson/resource'

module Munson
  # Configure the default connection.
  #
  # @param [Hash] opts {Munson::Connection} configuration options
  # @param [Proc] block to yield to Faraday::Connection
  # @return [Munson::Connection] the default connection

  # @see https://github.com/lostisland/faraday/blob/master/lib/faraday/connection.rb Faraday::Connection
  # @see Munson::Connection
  def self.configure(opts={}, &block)
    @default_connection = Munson::Connection.new(opts, &block)
  end

  # The default connection
  # @return [Munson::Connection, nil] the default connection if configured
  def self.default_connection
    defined?(@default_connection) ? @default_connection : nil
  end
end
