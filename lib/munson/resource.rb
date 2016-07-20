class Munson::Resource
  extend Forwardable
  attr_reader :document
  attr_reader :attributes
  def_delegators :document, :id

  # @example Given a Munson::Document
  #   document = Munson::Document.new(jsonapi_hash)
  #   Person.new(document)
  #
  # @example Given an attributes hash
  #   Person.new(first_name: "Chauncy", last_name: "Vünderboot")
  #
  # @param [Hash,Munson::Document] attrs
  def initialize(attrs = {})
    if attrs.is_a?(Munson::Document)
      @document = attrs
    else
      @document = Munson::Document.new(
        data: {
          type: self.class.type,
          attributes: attrs
        }
      )
    end

    initialize_attrs
  end

  def initialize_attrs
    @attributes = @document.attributes.clone
    self.class.schema.each do |name, attribute|
      casted_value = attribute.process(@attributes[name])
      @attributes[name] = casted_value
    end
  end

  def persisted?
    !id.nil?
  end

  def save
    document.save(serialized_attributes)
  end

  def serialized_attributes
    serialized_attrs = {}
    self.class.schema.each do |name, attribute|
      serialized_value = attribute.serialize(@attributes[name])
      serialized_attrs[name] = serialized_value
    end
    serialized_attrs
  end

  def ==(other)
    self.class.type == other.class.type && self.id == other.id
  end

  class << self
    def schema
      @schema ||= {}
    end

    def attribute(attribute_name, cast_type, **options)
      schema[attribute_name] = Munson::Attribute.new(attribute_name, cast_type, options)

      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{attribute_name}
          @attributes[:#{attribute_name}]
        end
      RUBY

      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{attribute_name}=(val)
          @attributes[:#{attribute_name}] = val
        end
      RUBY
    end

    def has_one(relation_name)
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{relation_name}
          return @_#{relation_name}_relationship if @_#{relation_name}_relationship
          related_document = document.relationship(:#{relation_name})
          @_#{relation_name}_relationship = Munson.factory(related_document)
        end
      RUBY
    end

    def has_many(relation_name)
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{relation_name}
          return @_#{relation_name}_relationship if @_#{relation_name}_relationship
          documents  = document.relationship(:#{relation_name})
          collection = Munson::Collection.new(documents.map{ |doc| Munson.factory(doc) })
          @_#{relation_name}_relationship = collection
        end
      RUBY
    end

    def munson_initializer(document)
      new(document)
    end

    def munson
      return @munson if @munson
      @munson = Munson::Client.new
      @munson
    end

    def type=(type)
      Munson.register_type(type, self)
      munson.type = type
    end

    def type
      munson.type
    end

    def fields(*args)
      hash_fields = args.last.is_a?(Hash) ? args.pop : {}
      hash_fields[type] = args if args.any?
      munson.fields(hash_fields)
    end

    [:include, :sort, :filter, :fetch, :find, :page].each do |method|
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{method}(*args)
          munson.#{method}(*args)
        end
      RUBY
    end
  end
end
