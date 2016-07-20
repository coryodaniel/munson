module Munson
  class Agent
    # Creates a new Munson::Agent
    #
    # @param [#to_s] path to JSON API Resource. Path will be added to the base path set in the Faraday::Connection
    # @param [Munson::Connection] connection to use
    def initialize(path, connection: nil)
      @path       = path
      @connection = connection
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
    # @return [Faraday::Response]
    def get(params: nil, path: nil, headers: nil)
      connection.get(
        path: (path || @path),
        params: params,
        headers: headers
      )
    end

    # JSON API Spec POST request
    #
    # @option [Hash,nil] body: {} query params
    # @option [String] path: nil path to GET, defaults to Faraday::Connection url + Agent#default_path
    # @option [Hash] headers: nil HTTP Headers
    # @option [Type] http_method: :post describe http_method: :post
    # @return [Faraday::Response]
    def post(body: {}, path: nil, headers: nil, http_method: :post)
      connection.post(
        path: (path || @path),
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
    # @return [Faraday::Response]
    def patch(body: nil, path: nil, headers: nil)
      post(body, path: path, headers: headers, http_method: :patch)
    end

    # JSON API Spec PUT request
    #
    # @option [Hash,nil] body: nil query params
    # @option [String] path: nil path to GET, defaults to Faraday::Connection url + Agent#default_path
    # @option [Hash] headers: nil HTTP Headers
    # @return [Faraday::Response]
    def put(body: nil, path: nil, headers: nil)
      post(body, path: path, headers: headers, http_method: :put)
    end

    # JSON API Spec DELETE request
    #
    # @option [Hash,nil] body: nil query params
    # @option [String] path: nil path to GET, defaults to Faraday::Connection url + Agent#default_path
    # @option [Hash] headers: nil HTTP Headers
    # @return [Faraday::Response]
    def delete(body: nil, path: nil, headers: nil)
      post(body, path: path, headers: headers, http_method: :delete)
    end
  end
end
