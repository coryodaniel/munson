require 'spec_helper'

describe Munson::Agent do
  describe '#get' do
    it 'returns a faraday response' do
      stub_api_request(:albums)

      agent = Munson::Agent.new('/albums')
      expect(agent.get).to have_data(:albums)
    end

    context 'when using a query' do
      it 'returns the parsed response' do
        stub_api_request(:albums_include_artist)
        
        agent = Munson::Agent.new('/albums')
        params = { include: 'artist' }

        response = agent.get(params: params)
        expect(response).to have_data(:albums_include_artist)
      end
    end
  end

  pending '#post'
  pending '#patch'
  pending '#delete'
  pending '#put'
end
