require 'spec_helper'

describe Munson::Connection do
  class TestMiddleware < Faraday::Middleware
    def call(env)
      @app.call(env)
    end
  end

  describe '#initialize' do
    it "configues the faraday connection" do
      connection = Munson::Connection.new(url: "http://example.com")
      expect(connection.faraday.url_prefix.to_s).to eq "http://example.com/"
    end

    context 'when passing a block' do
      it 'configures faraday middlware' do
        connection = Munson::Connection.new(url: "http://example.com") do |c|
          c.use TestMiddleware
        end

        expect(connection.faraday.builder.handlers).to include TestMiddleware
      end
    end
  end
end
