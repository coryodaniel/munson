module Munson
  class Agent
    attr_writer :connection
    attr_accessor :path
    attr_accessor :query_builder

    # Creates a new Munson::Agent
    #
    # @param [Hash] opts={} describe opts={}
    # @option opts [Munson::Connection] :connection to use
    # @option opts [#to_s] :path to use. It will be added to the base path set in the Faraday::Connection
    def initialize(opts={})
      @connection    = opts[:connection]
      @path          = opts[:path]
      @query_builder = Munson::QueryBuilder
    end

    # Munson::QueryBuilder factory
    #
    # @example creating a query
    #   @agent.query.includes('user').sort(age: :desc)
    #
    # @return [Munson::QueryBuilder] a query builder
    def query
      @query_builder.new
    end

    # Description of method
    #
    # @return [Munson::Connection] current connection of Munson::Agent or Munson.default_connection if not set
    def connection
      return @connection if @connection
      Munson.default_connection
    end

    def find(*ids, headers: nil, params: nil)
      responses = ids.uniq.map do |id|
        path = [self.path, id].join('/')
        get(path: path, headers: headers, params: params)
      end

      responses.length > 1 ? responses : responses.first
    end

    # JSON API Spec GET request
    #
    # @example building a query
    #   query = @agent.query.includes('user').sort(age: :desc)
    #   response = @agent.get(query.to_params)
    #
    # @option [Hash,nil] params: nil query params
    # @option [String] path: nil path to GET, defaults to Faraday::Connection url + Agent#type
    # @option [Hash] headers: nil HTTP Headers
    # @return [Faraday::Response]
    def get(params: nil, path: nil, headers: nil)
      path ||= self.path
      connection.faraday.get do |request|
        request.headers.merge!(headers) if headers
        request.url path.to_s, params
      end
    end

    # JSON API Spec POST request
    #
    # @option [Hash,nil] body: {} query params
    # @option [String] path: nil path to GET, defaults to Faraday::Connection url + Agent#type
    # @option [Hash] headers: nil HTTP Headers
    # @option [Type] method: :post describe method: :post
    # @return [Faraday::Response]
    def post(body: {}, path: nil, headers: nil, method: :post)
      path ||= self.path
      connection.faraday.get do |request|
        request.headers.merge!(headers) if headers
        request.url path.to_s
        request.body = body
      end
    end

    # JSON API Spec PATCH request
    #
    # @option [Hash,nil] body: nil query params
    # @option [String] path: nil path to GET, defaults to Faraday::Connection url + Agent#type
    # @option [Hash] headers: nil HTTP Headers
    # @return [Faraday::Response]
    def patch(body: nil, path: nil, headers: nil)
      post(body, path: path, headers: headers, method: :patch)
    end

    # JSON API Spec PUT request
    #
    # @option [Hash,nil] body: nil query params
    # @option [String] path: nil path to GET, defaults to Faraday::Connection url + Agent#type
    # @option [Hash] headers: nil HTTP Headers
    # @return [Faraday::Response]
    def put(body: nil, path: nil, headers: nil)
      post(body, path: path, headers: headers, method: :put)
    end

    # JSON API Spec DELETE request
    #
    # @option [Hash,nil] body: nil query params
    # @option [String] path: nil path to GET, defaults to Faraday::Connection url + Agent#type
    # @option [Hash] headers: nil HTTP Headers
    # @return [Faraday::Response]
    def delete(body: nil, path: nil, headers: nil)
      post(body, path: path, headers: headers, method: :delete)
    end
  end
end
