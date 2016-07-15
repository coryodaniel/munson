module Munson
  module RSpec
    module Macros
      module ModelMacros

        # spawn_agent("Article", type: :articles)
        def spawn_agent(class_name, base_class: nil, type: nil)
          type ||= class_name

          klass = spawn_class(class_name, base_class || Class.new) do
            def self.munson
              return @munson if @munson
              @munson = Munson::Agent.new
              @munson
            end

            def self.resource_initializer(data, included: included, errors: errors)
              json = { data: data }
              json[:included] = included if included
              json[:errors] = errors if errors
              new(json)
            end

            def initialize(json)
              @json = json
            end
          end

          klass.munson.type = type
          klass
        end

        def spawn_class(class_name, base_class, &block)
          Object.instance_eval { remove_const class_name } if Object.const_defined?(class_name)
          klass = Object.const_set(class_name, base_class)
          klass.class_eval(&block) if block_given?
          @spawned_models << class_name.to_sym
          klass
        end

        # @param [Hash] options
        # @option :inherit class to inherit from: Munson::Resource, Munson::Model
        def spawn_resource(class_name, type:)
          base_class = Class.new(Munson::Resource)
          klass = spawn_class(class_name, base_class)
          klass.register_munson_type(type)
        end
      end
    end
  end
end
