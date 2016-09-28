class Munson::Resource
  extend Forwardable
  attr_reader :document
  attr_reader :attributes

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
          id: attrs.delete(:id),
          attributes: attrs
        }
      )
    end

    initialize_attrs
  end

  def id
    return nil if document.id.nil?
    @id ||= self.class.format_id(document.id)
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
    @document = document.save(agent)
    !errors?
  end

  # @return [Array<Hash>] array of JSON API errors
  def errors
    document.errors
  end

  def errors?
    document.errors.any?
  end

  # @return [Munson::Agent] a new {Munson::Agent} instance
  def agent
    self.class.munson.agent
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
    return false if !other

    if other.class.respond_to?(:type)
      self.class.type == other.class.type && self.id == other.id
    else
      false
    end
  end

  class << self
    def inherited(subclass)
      if subclass.to_s.respond_to?(:tableize)
        subclass.type = subclass.to_s.tableize.to_sym
      end
    end

    def key_type(type)
      @key_type = type
    end

    def format_id(id)
      case @key_type
      when :integer, nil
        id.to_i
      when :string
        id.to_s
      when Proc
        @key_type.call(id)
      end
    end

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
          document.attributes[:#{attribute_name}] = self.class.schema[:#{attribute_name}].serialize(val)
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

    # Set the JSONAPI type
    def type=(type)
      Munson.register_type(type, self)
      munson.type = type
    end

    # Get the JSONAPI type
    def type
      munson.type
    end

    # Overwrite Connection#fields delegator to allow for passing an array of fields
    # @example
    #   Cat.fields(:name, :favorite_toy) #=> Query(fields[cats]=name,favorite_toy)
    #   Cat.fields(name, owner: [:name]) #=> Query(fields[cats]=name&fields[people]=name)
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
