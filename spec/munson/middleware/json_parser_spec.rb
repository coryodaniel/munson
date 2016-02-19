require 'spec_helper'

describe Munson::Middleware::JsonParser, type: :response do
  let(:document){ response_body(:articles_with_author) }


  let(:middleware) {
    described_class.new(lambda {|env|
      Faraday::Response.new(env)
    })
  }

  def faraday_env(body)
    env = {
      :body => body, :request => {},
      :request_headers => Faraday::Utils::Headers.new({}),
      :response_headers => Faraday::Utils::Headers.new({})
    }
    env[:response_headers]['content-type'] = 'application/vnd.api+json'
    env
  end

  context 'when the body is present' do
    it 'parses the body as JSON' do
      env = faraday_env(document)
      body = middleware.call(env).env.body

      expect(body).to match JSON.parse(document)
    end

    it 'stores the raw response' do
      env = faraday_env(document)
      raw_body = middleware.call(env).env[:raw_body]

      expect(raw_body).to eq document
    end
  end

  context 'when the body is empty' do
    it 'returns an empty hash' do
      env = faraday_env('')
      body = middleware.call(env).env.body
      expect(body).to eq({})
    end
  end
end
