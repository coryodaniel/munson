module Munson
  class ResponseMapper
    def initialize(response)
      @body = response.body
    end

    def data
      @body[:data]
    end

    def resources
      if data.is_a?(Array)
        Collection.new(data.map{ |datum| build_resource(datum) })
      else
        raise Munson::Error, "Called #resources, but response was a single resource. Use ResponseMapper#resource"
      end
    end

    def resource
      if data.is_a?(Hash)
        build_resource(data)
      else
        raise Munson::Error, "Called #resource, but response was a collection of resources. Use ResponseMapper#resources"
      end
    end

    private

    def build_resource(resource)
      klass = Munson.lookup_type(resource[:type])
      
      if klass && klass.respond_to?(:resource_initializer)
        klass.resource_initializer(resource, included: @body[:included], errors: @body[:errors])
      else
        json = { data: resource }
        json[:included] = @body[:included] if @body[:included]
        json[:errors] = @body[:errors] if @body[:errors]
        json
      end
    end
  end
end
