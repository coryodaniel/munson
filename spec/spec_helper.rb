$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require "codeclimate-test-reporter"
CodeClimate::TestReporter.start
SimpleCov.start
require 'webmock/rspec'
require 'pry-byebug'

require 'munson'

require 'support/macros/json_api_document_macros'
require 'support/macros/stub_request_macros'
require 'support/matchers/have_attr_accessor'
require 'support/matchers/have_data'

Munson.configure url: 'http://api.example.com'

Dir["spec/support/app/*"].each{ |f| load f }
WebMock.disable_net_connect!(allow: "codeclimate.com")

RSpec.configure do |c|
  c.include Munson::RSpec::Macros::JsonApiDocumentMacros
  c.include Munson::RSpec::Macros::StubRequestMacros

  c.before(:each) do
    Munson.configure url: 'http://api.example.com'
  end
end
