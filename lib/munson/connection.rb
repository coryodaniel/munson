module Munson
  # Faraday::Connection wrapper for making JSON API Requests
  #
  # @attr_reader [Faraday::Connection] faraday connection object
  # @attr_reader [Hash] options
  class Connection
    # @private
    attr_reader :faraday, :options

    FARADAY_OPTIONS = [:request, :proxy, :ssl, :builder, :url,
      :parallel_manager, :params, :headers, :builder_class].freeze

    # Create a new connection. A connection serves as a thin wrapper around a
    # a faraday connection that includes two pieces of middleware for handling
    # JSON API Spec
    #
    # @param [Hash] opts {Munson::Connection} configuration options
    # @param [Proc] block to yield to Faraday::Connection
    # @see https://github.com/lostisland/faraday/blob/master/lib/faraday/connection.rb Faraday::Connection
    #
    # @example Creating a new connection
    #   my_connection = Munson::Connection.new url: "http://api.example.com" do |c|
    #     c.use Your::Custom::Middleware
    #   end
    #
    #   class User
    #     include Munson::Resource
    #     munson.connection = my_connection
    #   end
    def initialize(opts, &block)
      configure(opts, &block)
    end

    # JSON API Spec GET request
    #
    # @example making a GET request
    #   @connection.get(path: 'addresses', params: {include: 'user'}, headers: {'X-API-Token' => '2kewl'})
    #
    # @option [Hash,nil] params: nil query params
    # @option [String] path: nil to GET
    # @option [Hash] headers: nil HTTP Headers
    # @return [Faraday::Response]
    def get(path: nil, params: nil, headers: nil)
      faraday.get do |request|
        request.headers.merge!(headers) if headers
        request.url path.to_s, params
      end
    end

    # JSON API Spec POST request
    #
    # @option [Hash,nil] body: {} query params
    # @option [String] path: nil path to GET, defaults to Faraday::Connection url + Agent#type
    # @option [Hash] headers: nil HTTP Headers
    # @option [Type] http_method: :post describe http_method: :post
    # @return [Faraday::Response]
    def post(body: {}, path: nil, headers: nil, http_method: :post)
      connection.faraday.send(http_method) do |request|
        request.headers.merge!(headers) if headers
        request.url path.to_s
        request.body = body
      end
    end


    # Configure the connection
    #
    # @param [Hash] opts {Munson::Connection} configuration options
    # @return Faraday::Connection
    #
    # @example Setting up the default API connection
    #   Munson::Connection.new url: "http://api.example.com"
    #
    # @example A custom middleware added to the default list
    #   class MyTokenAuth < Faraday::Middleware
    #     def call(env)
    #       env[:request_headers]["X-API-Token"] = "SECURE_TOKEN"
    #       @app.call(env)
    #     end
    #   end
    #
    #   Munson::Connection.new url: "http://api.example.com" do |c|
    #     c.use MyTokenAuth
    #   end
    def configure(opts={}, &block)
      @options = opts

      faraday_options = @options.reject { |key, value| !FARADAY_OPTIONS.include?(key.to_sym) }
      @faraday = Faraday.new(faraday_options) do |conn|
        yield conn if block_given?

        conn.use Munson::Middleware::EncodeJsonApi
        conn.use Munson::Middleware::JsonParser

        conn.adapter Faraday.default_adapter
      end
    end
  end
end
