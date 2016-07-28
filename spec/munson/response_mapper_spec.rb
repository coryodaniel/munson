require 'spec_helper'

describe Munson::ResponseMapper do
  describe '#jsonapi_resources' do
    it 'exposes all of the JSONAPI resources in the response' do
      json = response_json(:albums_include_artist)
      mapper = Munson::ResponseMapper.new(json)

      types = mapper.jsonapi_resources.map{ |r| r[:type] }.uniq
      expect(types).to eq %w(albums artists)
    end
  end

  context 'when processing a collection' do
    it 'sets top-level jsonapi "info" on the collection' do
      stub_api_request(:albums)
      document   = Album.munson.agent.get(path: '/albums').body
      collection = Munson::ResponseMapper.new(document).collection
      expect(collection.jsonapi[:version]).to eq "1.0"
    end

    it 'sets top-level jsonapi "links" on the collection' do
      stub_api_request(:albums)
      document   = Album.munson.agent.get(path: '/albums').body
      collection = Munson::ResponseMapper.new(document).collection
      expect(collection.links[:self]).to eq "http://api.example.com/albums/"
    end

    it 'sets top-level jsonapi "meta" data on the collection' do
      stub_api_request(:albums)
      document   = Album.munson.agent.get(path: '/albums').body
      collection = Munson::ResponseMapper.new(document).collection
      expect(collection.meta[:total_count]).to be 3
    end
  end

  describe 'when the type is registered' do
    context 'when processing a single resource' do
      it 'returns a "model"' do
        stub_api_request(:album_1)
        response = Album.munson.agent.get path: '/albums/1'

        mapper = Munson::ResponseMapper.new(response.body)
        expect(mapper.resource).to be_an(Album)
      end
    end

    it 'returns a collection of models' do
      stub_api_request(:albums)
      response = Album.munson.agent.get
      mapper = Munson::ResponseMapper.new(response.body)
      expect(mapper.collection.first).to be_an(Album)
    end
  end

  context 'when the type is not registered' do
    context 'when processing a single resource' do
      it 'returns a Munson::Document' do
        stub_api_request(:venue_1)
        response = Venue.munson.agent.get path: '/venues/1'
        resource = Munson::ResponseMapper.new(response.body).resource

        expect(resource).to be_a(Munson::Document)
        expect(resource.id). to eq "1"
        expect(resource.type).to eq :venues
      end
    end

    it 'returns Munson::Collection<Munson::Document>' do
      stub_api_request(:venues)
      response = Venue.munson.agent.get
      mapper = Munson::ResponseMapper.new(response.body)
      first_resource = mapper.collection.first

      expect(mapper.collection).to be_a(Munson::Collection)
      expect(first_resource).to be_a(Munson::Document)
      expect(first_resource.id).to eq "1"
      expect(first_resource.type).to eq :venues
    end
  end
end
