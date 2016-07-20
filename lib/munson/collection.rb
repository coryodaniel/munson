module Munson
  class Collection
    include Enumerable
    extend Forwardable
    def_delegator :@collection, :last
    
    attr_reader :meta
    attr_reader :jsonapi
    attr_reader :links

    def initialize(collection=[], errors: nil, meta: nil, jsonapi: nil, links: nil)
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
