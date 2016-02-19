module Munson
  class QueryBuilder
    attr_reader :query
    class UnsupportedSortDirectionError < StandardError; end;

    def initialize
      @query = {
        include: [],
        fields:  [],
        filter:  [],
        sort:    []
      }
    end

    # @example Output format
    #
    #   include=author,article.comments
    #   &fields[articles]=title,body&fields[people]=name
    #   &sort=-created,title
    #   &filter[name_last]=Smith
    #
    # TODO overridable by paginator
    def to_query
      to_params.to_query
    end

    def to_s
      to_query
    end

    def to_params
      str = {}
      str[:filter] = filter_to_query_value unless @query[:filter].empty?
      str[:fields] = fields_to_query_value unless @query[:fields].empty?
      str[:include] = includes_to_query_value unless @query[:include].empty?
      str[:sort] = sort_to_query_value unless @query[:sort].empty?
      str
    end

    # Chainably include related resources.
    #
    # @example including a resource
    #   Munson::QueryBuilder.new.includes(:user)
    #
    # @example including a related resource
    #   Munson::QueryBuilder.new.includes("user.addresses")
    #
    # @example including multiple resources
    #   Munson::QueryBuilder.new.includes("user.addresses", "user.images")
    #
    # @param [Array<String,Symbol>] *args relationships to include
    # @return [Munson::QueryBuilder] self for chaining queries
    #
    # @see http://jsonapi.org/format/#fetching-includes JSON API Including Relationships
    def includes(*args)
      @query[:include] += args
      self
    end

    # Chainably sort results
    # @note Default order is ascending
    #
    # @example sorting by a single field
    #   Munsun::QueryBuilder.new.sort(:created_at)
    #
    # @example sorting by a multiple fields
    #   Munsun::QueryBuilder.new.sort(:created_at, :age)
    #
    # @example specifying sort direction
    #   Munsun::QueryBuilder.new.sort(:created_at, age: :desc)
    #
    # @example specifying sort direction
    #   Munsun::QueryBuilder.new.sort(score: :desc, :created_at)
    #
    # @param [Hash<Symbol,Symbol>, Symbol] *args fields to sort by
    # @return [Munson::QueryBuilder] self for chaining queries
    #
    # @see http://jsonapi.org/format/#fetching-sorting JSON API Sorting Spec
    def sort(*args)
      validate_sort_args(args.select{|arg| arg.is_a?(Hash)})
      @query[:sort] += args
      self
    end

    # Hash resouce_name: [array of attribs]
    def fields(*args)
      @query[:fields] += args
      self
    end

    def filter(*args)
      @query[:filter] += args
      self
    end

    def self.includes(*args)
      new.includes(*args)
    end

    def self.sort(*args)
      new.sort(*args)
    end

    def self.fields(*args)
      new.fields(*args)
    end

    def self.filter(*args)
      new.filter(*args)
    end

    protected

    def sort_to_query_value
      @query[:sort].map{|item|
        if item.is_a?(Hash)
          item.to_a.map{|name,dir|
            dir.to_sym == :desc ? "-#{name}" : name.to_s
          }
        else
          item.to_s
        end
      }.join(',')
    end

    def fields_to_query_value
      @query[:fields].inject({}) do |acc, hash_arg|
        hash_arg.each do |k,v|
          acc[k] ||= []
          v.is_a?(Array) ?
            acc[k] += v :
            acc[k] << v

          acc[k].map(&:to_s).uniq!
        end

        acc
      end.map { |k, v| [k, v.join(',')] }.to_h
    end

    def includes_to_query_value
      @query[:include].map(&:to_s).sort.join(',')
    end

    # Since the filter query param's format isn't specified in the [spec](http://jsonapi.org/format/#fetching-filtering)
    # this implemenation uses (JSONAPI::Resource's implementation](https://github.com/cerebris/jsonapi-resources#filters)
    #
    # TODO: This should be made pluggable, maybe via exposing a query builder class to the Munson::Agent
    #
    def filter_to_query_value
      @query[:filter].reduce({}) do |acc, hash_arg|
        hash_arg.each do |k,v|
          acc[k] ||= []
          v.is_a?(Array) ? acc[k] += v : acc[k] << v
          acc[k].uniq!
        end
        acc
      end.map { |k, v| [k, v.join(',')] }.to_h
    end

    def validate_sort_args(hashes)
      hashes.each do |hash|
        hash.each do |k,v|
          if !%i(desc asc).include?(v.to_sym)
            raise UnsupportedSortDirectionError, "Unknown direction '#{v}'. Use :asc or :desc"
          end
        end
      end
    end
  end
end
