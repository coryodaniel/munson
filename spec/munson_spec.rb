require 'spec_helper'

describe Munson do
  it 'has a version number' do
    expect(Munson::VERSION).not_to be nil
  end

  describe '.configure' do
    it "sets the default connection" do
      Munson.configure url: "http://example.com" do |c|
        c.use TestMiddleware
      end

      expect(Munson.default_connection).to be_a(Munson::Connection)
      expect(Munson.default_connection.faraday.url_prefix.to_s).to eq "http://example.com/"
    end
  end
end
