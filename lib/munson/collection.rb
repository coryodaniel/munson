module Munson
  class Collection
    include Enumerable
    extend Forwardable
    def_delegator :@collection, :last

    attr_reader :meta
    attr_reader :jsonapi
    attr_reader :links

    def initialize(collection=[], opts = {})
      errors  = opts[:errors]
      meta    = opts[:meta]
      jsonapi = opts[:jsonapi]
      links   = opts[:links]

      @collection = collection
      @meta       = meta
      @jsonapi    = jsonapi
      @links      = links
    end

    def each(&block)
      @collection.each(&block)
    end
  end
end
