module Munson
  class Client
    extend Forwardable
    def_delegators :query, :include, :sort, :filter, :fields, :fetch, :fetch_from, :page, :find
    def_delegators :connection, :url=, :url, :response_key_format, :response_key_format=

    attr_writer :path
    attr_writer :query_builder
    attr_accessor :type

    def initialize(opts={})
      opts.each do |k,v|
        setter = "#{k}="
        send(setter,v) if respond_to?(setter)
      end
    end

    def query
      (@query_builder || Query).new(self)
    end

    def agent
      Agent.new(path, connection: connection)
    end

    def path
      @path || type.to_s
    end

    def configure(&block)
      yield(self)
      self
    end

    def connection
      @connection ||= Munson.default_connection.clone
    end

    def connection=(connection)
      @connection = connection
    end
  end
end
