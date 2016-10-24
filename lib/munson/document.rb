require 'core_ext/object/deep_dup'

module Munson
  class Document
    attr_accessor :id
    attr_reader :type

    def initialize(jsonapi_document)
      @id   = jsonapi_document[:data][:id]
      @type = jsonapi_document[:data][:type].to_sym
      @jsonapi_document = jsonapi_document

      if jsonapi_document[:data] && jsonapi_document[:data][:attributes]
        @original_attributes = jsonapi_document[:data][:attributes]
        @attributes          = jsonapi_document[:data][:attributes].deep_dup
      else
        @original_attributes = {}
        @attributes          = {}
      end
    end

    # @return [Hash] hash for persisting this JSON API Resource via POST/PATCH/PUT
    def payload
      doc = { data: { type: @type } }
      if id
        doc[:data][:id] = id
        doc[:data][:attributes] = changed
      else
        doc[:data][:attributes] = attributes
      end
      doc
    end

    def data
      @jsonapi_document[:data]
    end

    def included
      @jsonapi_document[:included] || []
    end

    def attributes
      @attributes
    end

    def attributes=(attrs)
      @attributes.merge!(attrs)
    end

    def changes
      attributes.reduce({}) do |memo, (k,v)|
        if @original_attributes[k] != attributes[k]
          memo[k] = [@original_attributes[k], attributes[k]]
        end
        memo
      end
    end

    def changed
      attributes.reduce({}) do |memo, (k,v)|
        if @original_attributes[k] != attributes[k]
          memo[k] = attributes[k]
        end
        memo
      end
    end

    def save(agent)
      response = if id
        agent.patch(id: id.to_s, body: payload)
      else
        agent.post(body: payload)
      end

      Munson::Document.new(response.body)
    end

    def url
      links[:self]
    end

    def [](key)
      attributes[key]
    end

    def errors
      data[:errors] || []
    end

    # Raw relationship hashes
    def relationships
      data[:relationships] || {}
    end

    def links
      data[:links] || {}
    end

    def meta
      data[:meta] || {}
    end

    # Initialized {Munson::Document} from #relationships
    # @param [Symbol] name of relationship
    def relationship(name)
      if relationship_data(name).is_a?(Array)
        relationship_data(name).map { |meta_data| find_included_item(meta_data) }
      elsif relationship_data(name).is_a?(Hash)
        find_included_item(relationship_data(name))
      else
        raise RelationshipNotFound, <<-ERR
        The relationship `#{name}` was called, but does not exist on the document.
        Relationships available are: #{relationships.keys.join(',')}
        ERR
      end
    end

    def relationship_data(name)
      relationships[name] ? relationships[name][:data] : nil
    end

    # @param [Hash] relationship from JSONAPI relationships hash
    # @return [Munson::Document,nil] the included relationship, if found
    private def find_included_item(relationship)
      resource = included.find do |included_resource|
        included_resource[:type] == relationship[:type] &&
          included_resource[:id] == relationship[:id]
      end

      if resource
        Document.new(data: resource, included: included)
      else
        raise RelationshipNotIncludedError, <<-ERR
        The relationship `#{relationship[:type]}` was called,
        but it was not included in the request.

        Try adding `include=#{relationship[:type]}` to your query.
        ERR
      end
    end
  end
end
