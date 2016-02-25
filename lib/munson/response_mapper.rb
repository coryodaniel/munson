module Munson
  class ResponseMapper
    class UnsupportedDatatype < StandardError;end;

    def initialize(response)
      @data     = response.body[:data]
      @includes = response.body[:include]
    end

    def resources
      if data_is_collection?
        map_data(@data)
      else
        raise StandardError, "Called #resources, but response was a single resource. Use ResponseMapper#resource"
      end
    end

    def resource
      if data_is_resource?
        map_data(@data)
      else
        raise StandardError, "Called #resource, but response was a collection of resources. Use ResponseMapper#resources"
      end
    end

    private

    def data_is_resource?
      @data.is_a?(Hash)
    end

    def data_is_collection?
      @data.is_a?(Array)
    end

    def map_data(data)
      if data_is_collection?
        @data.map{ |datum| map_resource(datum) }
      elsif data_is_resource?
        map_resource(@data)
      else
        raise UnsupportedDatatype, "No mapping rule for #{data.class}"
      end
    end

    def map_resource(resource)
      if klass = Munson.lookup_type(resource[:type])
        klass.new(resource[:attributes].merge(id: resource[:id]))
      else
        resource
      end
    end
  end
end
