module Munson
  module RSpec
    module Macros
      module ModelMacros

        # spawn_agent("Article", type: :articles)
        def spawn_agent(klass, type: nil)
          type ||= klass

          spawn_model(klass, include: nil, type: type) do
            def self.munson
              return @munson if @munson
              @munson = Munson::Agent.new
              @munson
            end

            munson.connection #=> Default Connection
            munson.type = type
          end
        end

        # @param [Hash] options
        # @option :include munson agent include: Munson::Resource, Munson::Model
        def spawn_model(klass, options={}, &block)
          super_class = options[:super_class]
          new_class = super_class ? Class.new(super_class) : Class.new
          munson_include = options.has_key?(:include) ? options[:include] : Munson::Resource

          if klass =~ /::/
            base, submodel = klass.split(/::/).map{ |s| s.to_sym }
            Object.const_set(base, Module.new) unless Object.const_defined?(base)
            Object.const_get(base).module_eval do
              remove_const submodel if constants.map(&:to_sym).include?(submodel)
              submodel = const_set(submodel, new_class)
              submodel.send(:include, munson_include) if munson_include
              submodel.class_eval do
                def initialize(*args)
                  @args = args
                end
              end
              submodel.class_eval(&block) if block_given?
              submodel.register_munson_type(options[:type]) if options[:type]
            end

            @spawned_models << base
          else
            Object.instance_eval { remove_const klass } if Object.const_defined?(klass)
            Object.const_set(klass, Class.new)
            model = Object.const_get(klass)
            model.send(:include, munson_include) if munson_include

            model.class_eval do
              def initialize(args)
                @args = args
              end
            end
            model.class_eval(&block) if block_given?
            model.munson.type = options[:type] if options[:type]

            if model.respond_to?(:register_munson_type) && options[:type]
              model.register_munson_type(options[:type])
            end

            @spawned_models << klass.to_sym
          end
        end
      end
    end
  end
end
