require 'spec_helper'

class FooResource < Munson::Resource
  self.type = :foos
end

describe Munson::Resource do
  before { FooResource.instance_variable_set("@schema",{}) }

  describe '.attribute' do
    it "adds the attribute to the Resource's schema" do
      expect { FooResource.attribute :name, :to_s }.
        to change{FooResource.schema.empty?}.
        from(true).to(false)
    end

    context 'when initializing an object' do
      context 'when the default is set' do
        it 'sets the default for a given attribute' do
          FooResource.attribute :color, :to_s, default: "red"
          resource = FooResource.new
          expect(resource.color).to eq "red"
        end
      end

      context 'when the default is set via a proc' do
        it 'sets the default for a given attribute' do
          FooResource.attribute :color, :to_s, default: -> { "red" }
          resource = FooResource.new
          expect(resource.color).to eq "red"
        end
      end
    end
  end

  describe "#save" do
    it "sends the attributes to the Munson::Document" do
      stub_api_request(:artist_9)
      artist = Artist.find(9)
      artist.name = "Elton John"
      artist.twitter = "@TheJohn"

      expect(artist.document).to receive(:save).with(name: 'Elton John', twitter: '@TheJohn')
      artist.save
    end
  end

  describe '#persisted?' do
    context 'when the document has an ID' do
      it 'is persisted' do
        stub_api_request(:artist_9)
        artist = Artist.find(9)
        expect(artist).to be_persisted
      end
    end

    context 'when the document does not have an ID' do
      it 'is not persisted' do
        artist = Artist.new
        expect(artist).to_not be_persisted
      end
    end
  end

  describe '.self.type = ' do
    before { Artist.type = :artists }
    after { Artist.type = :artists }
    it 'registers the type w/ Munson' do
      expect{ Artist.type =  "pickles" }.
        to change{ Munson.lookup_type(:pickles) }.from(nil).to(Artist)
    end

    it 'sets the agents type' do
      expect{ Artist.type = :bands }.
        to change{ Artist.munson.type }.from(:artists).to(:bands)
    end
  end

  describe 'relationships' do
    context 'when the type is a Munson::Resource' do
      it "returns a Munson::Collection of Munson::Resource" do
        stub_api_request(:artist_9_include_members)
        artist = Artist.include('members').find(9)

        expect(artist.members).to be_a(Munson::Collection)
        expect(artist.members.first).to be_a(Member)
        expect(artist.members.first.name).to eq "Colin Meloy"
      end
    end

    context 'when the type is registered, but not a Munson::Resource' do
      it "returns a Munson::Collection of objects" do
        stub_api_request(:artist_9_include_albums)
        artist = Artist.include('albums').find(9)

        expect(artist.albums).to be_a(Munson::Collection)
        expect(artist.albums.first).to be_a(Album)
        expect(artist.albums.first.title).to eq "The Crane Wife"
      end
    end

    context 'when the type is not registered' do
      it "returns a Munson::Document" do
        stub_api_request(:artist_9_include_albums_record_label)
        artist = Artist.include(:albums,:record_label).find(9)

        expect(artist.record_label).to be_a(Munson::Document)
        expect(artist.record_label[:name]).to eq "Capitol Records"
      end
    end
  end

  describe '.find' do
    it 'returns the resource' do
      stub_api_request(:artist_9)
      artist = Artist.find(9)
      expect(artist).to be_an(Artist)
    end
  end

  describe '#id' do
    it 'returns the resource ID' do
      stub_api_request(:artist_9)
      artist = Artist.find(9)
      expect(artist.id).to eq "9"
    end
  end

  describe '.fields' do
    it "returns a Query" do
      query = Artist.fields(artists: [:name, :twitter], albums: [:name])
      fields = query.to_params[:fields]

      expect(fields).to eq(artists: "name,twitter", albums: "name")
    end

    context "given an array and a hash" do
      it "automatically wraps the array elements with the type name" do
        query = Artist.fields(:name, :twitter, albums: [:name])
        fields = query.to_params[:fields]

        expect(fields).to eq(artists: "name,twitter", albums: "name")
      end
    end

    context "given an array" do
      it "automatically wraps the array elements with the type name" do
        query = Artist.fields(:name, :twitter)
        fields = query.to_params[:fields]

        expect(fields).to eq(artists: "name,twitter")
      end
    end
  end

  describe '.includes' do
    it 'returns a Query' do
      query = Artist.include(:albums)
      expect(query).to be_a Munson::Query
    end
  end

  describe '.page' do
    it 'returns a Query' do
      query = Artist.page(limit: 100)
      expect(query).to be_a Munson::Query
    end
  end

  describe '.filter' do
    it 'returns a Query' do
      query = Artist.filter(category: 'kittens')
      expect(query).to be_a Munson::Query
    end
  end

  describe '.sort' do
    it 'returns a Query' do
      query = Artist.sort(:name)
      expect(query).to be_a Munson::Query
    end
  end

  describe '.update' do
    pending "Resource.update(id,{})"
  end

  describe '.destroy' do
    pending "Resource.destroy(id)"
  end

  describe '#destroy' do
    pending "Resource#destroy"
  end

  describe '.all' do
    pending "Resource.all{ |article| paging...}"
  end
end
