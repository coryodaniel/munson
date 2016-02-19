require 'spec_helper'

describe Munson::Middleware::EncodeJsonApi do
  let(:middleware) { described_class.new(lambda{|env| env}) }

  def faraday_env(env)
    if defined?(Faraday::Env)
      Faraday::Env.from(env)
    else
      env
    end
  end

  def process(body, content_type = nil)
    env = {:body => body, :request_headers => Faraday::Utils::Headers.new}
    env[:request_headers]['content-type'] = content_type if content_type
    middleware.call(faraday_env(env))
  end

  def result_body() result[:body] end
  def result_type() result[:request_headers]['content-type'] end

  context "no body" do
    let(:result) { process(nil) }

    it "doesn't change body" do
      expect(result_body).to be_nil
    end

    it "doesn't add content type" do
      expect(result_type).to be_nil
    end
  end

  context "empty body" do
    let(:result) { process('') }

    it "doesn't change body" do
      expect(result_body).to be_empty
    end

    it "doesn't add content type" do
      expect(result_type).to be_nil
    end
  end

  context "string body" do
    let(:result) { process('{"a":1}') }

    it "doesn't change body" do
      expect(result_body).to eq('{"a":1}')
    end

    it "adds content type" do
      expect(result_type).to eq('application/vnd.api+json')
    end
  end

  context "empty object body" do
    let(:result) { process({}) }

    it "encodes body" do
      expect(result_body).to eq('{}')
    end
  end

  context "object body" do
    let(:result) { process({:a => 1}) }

    it "encodes body" do
      expect(result_body).to eq('{"a":1}')
    end

    it "adds content type" do
      expect(result_type).to eq('application/vnd.api+json')
    end
  end
end
