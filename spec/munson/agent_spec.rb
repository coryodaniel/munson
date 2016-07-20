require 'spec_helper'

describe Munson::Agent do
  describe '#get' do
    it 'returns a faraday response' do
      agent = Munson::Agent.new('/albums')
      expect(agent.get).to have_data(:albums)
    end

    context 'when using a query' do
      it 'returns the parsed response' do
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
