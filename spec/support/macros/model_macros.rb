module Munson
  module RSpec
    module Macros
      module ModelMacros

        # spawn_agent("Article")
        def spawn_agent(klass)
          spawn_model(klass, type: nil) do
            def self.munson
              return @munson if @munson
              @munson = Munson::Agent.new
              @munson
            end

            munson.connection #=> Default Connection
            munson.type = klass.demodulize.tableize
          end
        end

        # @param [Hash] options
        # @option :type munson type type: Munson::Resource, Munson::Model
        def spawn_model(klass, options={}, &block)
          super_class = options[:super_class]
          new_class = super_class ? Class.new(super_class) : Class.new
          munson_type = options.has_key?(:type) ? options[:type] : Munson::Resource

          if klass =~ /::/
            base, submodel = klass.split(/::/).map{ |s| s.to_sym }
            Object.const_set(base, Module.new) unless Object.const_defined?(base)
            Object.const_get(base).module_eval do
              remove_const submodel if constants.map(&:to_sym).include?(submodel)
              submodel = const_set(submodel, new_class)

              submodel.send(:include, munson_type) if munson_type
              submodel.class_eval do
                def initialize(*args)
                  @args = args
                end
              end
              submodel.class_eval(&block) if block_given?
            end

            @spawned_models << base
          else
            Object.instance_eval { remove_const klass } if Object.const_defined?(klass)
            Object.const_set(klass, Class.new)
            Object.const_get(klass).send(:include, munson_type) if munson_type
            Object.const_get(klass).class_eval do
              def initialize(*args)
                @args = args
              end
            end
            Object.const_get(klass).class_eval(&block) if block_given?

            @spawned_models << klass.to_sym
          end
        end
      end
    end
  end
end
