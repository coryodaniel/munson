module Munson
  class Agent
    # Creates a new Munson::Agent
    #
    # @param [#to_s] path to JSON API Resource. Path will be added to the base path set in the Faraday::Connection
    # @param [Munson::Connection] :connection object
    def initialize(path, opts = {})
      @path       = path
      @connection = opts[:connection]
    end

    # Connection that will be used for HTTP requests
    #
    # @return [Munson::Connection] current connection of Munson::Agent or Munson.default_connection if not set
    def connection
      return @connection if @connection
      Munson.default_connection
    end

    # JSON API Spec GET request
    #
    # @option [Hash,nil] params: nil query params
    # @option [String] path: nil path to GET, defaults to Faraday::Connection url + Agent#default_path
    # @option [Hash] headers: nil HTTP Headers
    # @option [String,Fixnum] id: nil ID to append to @path (provided in #new) when accessing a resource. If :path and :id are both specified, :path wins
    # @return [Faraday::Response]
    def get(opts = {})
      params  = opts[:params]
      path    = opts[:path]
      headers = opts[:headers]
      id      = opts[:id]

      connection.get(
        path: negotiate_path(path, id),
        params: params,
        headers: headers
      )
    end

    def negotiate_path(path = nil, id = nil)
      if path
        path
      elsif id
        [@path, id].join('/')
      else
        @path
      end
    end

    # JSON API Spec POST request
    #
    # @option [Hash,nil] body: {} query params
    # @option [String] path: nil path to GET, defaults to Faraday::Connection url + Agent#default_path
    # @option [Hash] headers: nil HTTP Headers
    # @option [Type] http_method: :post describe http_method: :post
    # @option [String,Fixnum] id: nil ID to append to default path when accessing a resource. If :path and :id are both specified, :path wins
    # @return [Faraday::Response]
    def post(opts = {})
      body        = opts[:body] || {}
      path        = opts[:path]
      headers     = opts[:headers]
      http_method = opts[:http_method] || :post
      id          = opts[:id]

      connection.post(
        path: negotiate_path(path, id),
        body: body,
        headers: headers,
        http_method: http_method
      )
    end

    # JSON API Spec PATCH request
    #
    # @option [Hash,nil] body: nil query params
    # @option [String] path: nil path to GET, defaults to Faraday::Connection url + Agent#default_path
    # @option [Hash] headers: nil HTTP Headers
    # @option [String,Fixnum] id: nil ID to append to default path when accessing a resource. If :path and :id are both specified, :path wins
    # @return [Faraday::Response]
    def patch(opts = {})
      body        = opts[:body] || {}
      path        = opts[:path]
      headers     = opts[:headers]
      id          = opts[:id]

      post(body: body, path: path, headers: headers, http_method: :patch, id: id)
    end

    # JSON API Spec PUT request
    #
    # @option [Hash,nil] body: nil query params
    # @option [String] path: nil path to GET, defaults to Faraday::Connection url + Agent#default_path
    # @option [Hash] headers: nil HTTP Headers
    # @option [String,Fixnum] id: nil ID to append to default path when accessing a resource. If :path and :id are both specified, :path wins
    # @return [Faraday::Response]
    def put(opts = {})
      body        = opts[:body] || {}
      path        = opts[:path]
      headers     = opts[:headers]
      id          = opts[:id]
      post(body: body, path: path, headers: headers, http_method: :put, id: id)
    end

    # JSON API Spec DELETE request
    #
    # @option [Hash,nil] body: nil query params
    # @option [String] path: nil path to GET, defaults to Faraday::Connection url + Agent#default_path
    # @option [Hash] headers: nil HTTP Headers
    # @option [String,Fixnum] id: nil ID to append to default path when accessing a resource. If :path and :id are both specified, :path wins
    # @return [Faraday::Response]
    def delete(opts = {})
      body        = opts[:body] || {}
      path        = opts[:path]
      headers     = opts[:headers]
      id          = opts[:id]
      post(body: body, path: path, headers: headers, http_method: :delete, id: id)
    end
  end
end
