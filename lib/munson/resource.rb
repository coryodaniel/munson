class Munson::Resource
  attr_reader :attributes
  attr_reader :id

  def initialize(data, included: nil, errors: nil)
    @id = data[:id]
    @attributes = data[:attributes]
    @included = included
    @errors = errors

    attributes.each do |k,v|
      setter = "#{k}="
      send(setter, v) if respond_to?(setter)
    end
  end

  class << self
    def munson
      return @munson if @munson
      @munson = Munson::Agent.new
      @munson
    end

    def resource_initializer(resource, included: nil, errors: nil)
      new(resource, included: included, errors: errors)
    end

    def register_munson_type(name)
      Munson.register_type(name, self)
      self.munson.type = name
    end

    [:includes, :sort, :filter, :fields, :fetch, :find, :page].each do |method|
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{method}(*args)
          munson.#{method}(*args)
        end
      RUBY
    end
  end
end
