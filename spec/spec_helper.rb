$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require "codeclimate-test-reporter"
CodeClimate::TestReporter.start
require 'webmock/rspec'
require 'munson'
require 'pry-byebug'

require 'support/macros/json_api_document_macros'
require 'support/macros/model_macros'
require 'support/matchers/have_data'

WebMock.disable_net_connect!(:allow => "codeclimate.com")

RSpec.configure do |c|
  c.include Munson::RSpec::Macros::JsonApiDocumentMacros
  c.include Munson::RSpec::Macros::ModelMacros

  c.before(:each){ @spawned_models = [] }
  c.after :each do
    Munson.flush_types!
    @spawned_models.each do |model|
      Object.instance_eval { remove_const model } if Object.const_defined?(model)
    end
  end
end

# Maybe scratch all the model generation for something a little more simple...
# class Person
#   def self.munson
#     return @munson if @munson
#     @munson = Munson::Agent.new
#     @munson
#   end
#   munson.type = :people
# end
#
# class Article
#   def self.munson
#     return @munson if @munson
#     @munson = Munson::Agent.new
#     @munson
#   end
#   munson.type = :articles
#
#   def self.resource_initializer(data, included: included, errors: errors)
#     json = {
#       data: data,
#       included: included
#     }
#     json[:errors] if errors
#
#     new(json)
#   end
#
#   attr_reader :json
#   def initialize(json)
#     @json = json
#   end
# end
#

# class Post < Munson::Resource
#   register_munson_type :articles
# end
