module Munson
  class Agent
    extend Forwardable
    def_delegators :query, :includes, :sort, :filter, :fields, :fetch, :page

    attr_writer :connection

    attr_accessor :type
    attr_accessor :query_builder

    attr_reader :paginator
    attr_accessor :paginator_options

    # Creates a new Munson::Agent
    #
    # @param [Hash] opts={} describe opts={}
    # @option opts [Munson::Connection] :connection to use
    # @option opts [#to_s, Munson::Paginator] :paginator to use on query builder
    # @option opts [Class] :query_builder provide a custom query builder, defaults to {Munson::QueryBuilder}
    # @option opts [#to_s] :type JSON Spec type. Type will be added to the base path set in the Faraday::Connection
    def initialize(opts={})
      @connection    = opts[:connection]
      @type          = opts[:type]

      @query_builder = opts[:query_builder].is_a?(Class) ?
        opts[:query_builder] : Munson::QueryBuilder

      self.paginator     = opts[:paginator]
      @paginator_options = opts[:paginator_options]
    end

    def paginator=(pager)
      if pager.is_a?(Symbol)
        @paginator = "Munson::Paginator::#{pager.to_s.classify}Paginator".constantize
      else
        @paginator = pager
      end
    end

    # Munson::QueryBuilder factory
    #
    # @example creating a query
    #   @agent.includes('user').sort(age: :desc)
    #
    # @return [Munson::QueryBuilder] a query builder
    def query
      if paginator
        query_pager = paginator.new(paginator_options || {})
        @query_builder.new paginator: query_pager, agent: self
      else
        @query_builder.new agent: self
      end
    end

    # Connection that will be used for HTTP requests
    #
    # @return [Munson::Connection] current connection of Munson::Agent or Munson.default_connection if not set
    def connection
      return @connection if @connection
      Munson.default_connection
    end

    def find(id, headers: nil, params: nil)
      path = [type, id].join('/')
      response = get(path: path, headers: headers, params: params)
      ResponseMapper.new(response).resource
    end

    # JSON API Spec GET request
    #
    # @option [Hash,nil] params: nil query params
    # @option [String] path: nil path to GET, defaults to Faraday::Connection url + Agent#type
    # @option [Hash] headers: nil HTTP Headers
    # @return [Faraday::Response]
    def get(params: nil, path: nil, headers: nil)
      connection.get(
        path: (path || type),
        params: params,
        headers: headers
      )
    end

    # JSON API Spec POST request
    #
    # @option [Hash,nil] body: {} query params
    # @option [String] path: nil path to GET, defaults to Faraday::Connection url + Agent#type
    # @option [Hash] headers: nil HTTP Headers
    # @option [Type] http_method: :post describe http_method: :post
    # @return [Faraday::Response]
    def post(body: {}, path: nil, headers: nil, http_method: :post)
      connection.post(
        path: (path || type),
        body: body,
        headers: headers,
        http_method: http_method
      )
    end

    # JSON API Spec PATCH request
    #
    # @option [Hash,nil] body: nil query params
    # @option [String] path: nil path to GET, defaults to Faraday::Connection url + Agent#type
    # @option [Hash] headers: nil HTTP Headers
    # @return [Faraday::Response]
    def patch(body: nil, path: nil, headers: nil)
      post(body, path: path, headers: headers, http_method: :patch)
    end

    # JSON API Spec PUT request
    #
    # @option [Hash,nil] body: nil query params
    # @option [String] path: nil path to GET, defaults to Faraday::Connection url + Agent#type
    # @option [Hash] headers: nil HTTP Headers
    # @return [Faraday::Response]
    def put(body: nil, path: nil, headers: nil)
      post(body, path: path, headers: headers, http_method: :put)
    end

    # JSON API Spec DELETE request
    #
    # @option [Hash,nil] body: nil query params
    # @option [String] path: nil path to GET, defaults to Faraday::Connection url + Agent#type
    # @option [Hash] headers: nil HTTP Headers
    # @return [Faraday::Response]
    def delete(body: nil, path: nil, headers: nil)
      post(body, path: path, headers: headers, http_method: :delete)
    end
  end
end
