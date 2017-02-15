require 'spec_helper'

describe Munson::Query do
  pending '#each'
  pending '#all' #block pages through while results are present (links,meta count)

  describe '#find' do
    it 'returns a mapped resource' do
      stub_api_request(:album_1_include_artist)

      client = Munson::Client.new(type: :albums)
      query  = Munson::Query.new(client)
      album  = query.include(:artist).find(1)

      expect(album).to be_a(Album)
    end
  end

  describe '#fetch' do
    it 'returns a Munson::Collection' do
      stub_api_request(:albums_include_artist)

      client = Munson::Client.new(type: :albums)
      query   = Munson::Query.new(client)
      albums  = query.include(:artist).fetch

      expect(albums).to be_a(Munson::Collection)
      expect(albums.first).to be_a(Album)
    end
  end

  describe '#fetch_from' do
    it 'returns a Munson::Collection' do
      stub_api_request(:albums_top_include_artist)

      client = Munson::Client.new(type: :albums)
      query   = Munson::Query.new(client)
      albums  = query.include(:artist).fetch_from('/top')

      expect(albums).to be_a(Munson::Collection)
      expect(albums.first).to be_a(Album)
    end
  end

  describe '#to_query_string' do
    describe 'doing all the things' do
      it 'generates a query string' do
        query = Munson::Query.new.
          filter(state: 'read').sort(received_at: :desc).
          fields(email: :subject).include(:sender)

        expect(query.to_query_string)
          .to eq("fields%5Bemail%5D=subject&filter%5Bstate%5D=read&include=sender&sort=-received_at")
      end
    end

    describe ':filter' do
      it 'returns a shallow hash' do
        query = Munson::Query.new.filter(state: 'read').filter(state: 'unread')
        expect(query.to_query_string).to eq "filter%5Bstate%5D=read%2Cunread"
      end

      it 'returns a shallow hash' do
        query = Munson::Query.new.filter(min_age: 30, max_age: 65)
        expect(query.to_query_string).to eq "filter%5Bmax_age%5D=65&filter%5Bmin_age%5D=30"
      end

      it 'returns a shallow hash' do
        query = Munson::Query.new.filter(min_age: 30).filter(max_age: 65)
        expect(query.to_query_string).to eq "filter%5Bmax_age%5D=65&filter%5Bmin_age%5D=30"
      end
    end

    describe ':fields' do
      context 'given a hash of symbols and arrays' do
        it '' do
          query = Munson::Query.new.fields(users: [:first_name])
          expect(query.to_query_string).to eq "fields%5Busers%5D=first_name"
        end
      end

      context 'given a hash of symbols and symbols' do
        it 'wraps the symbol in an array' do
          query = Munson::Query.new.fields(users: :first_name).fields(addresses: :postal_code)
          expect(query.to_query_string).to eq "fields%5Baddresses%5D=postal_code&fields%5Busers%5D=first_name"
        end
      end

      context 'given multiple hashes' do
        it 'merges the hashes' do
          query = Munson::Query.new.fields(users: [:first_name, :last_name], addresses: :postal_code)
          expect(query.to_query_string).to eq "fields%5Baddresses%5D=postal_code&fields%5Busers%5D=first_name%2Clast_name"
        end
      end
    end

    describe ':sort' do
      context 'given a symbol and a hash' do
        it 'creates a comma separated list' do
          query = Munson::Query.new.sort(:created_at, score: :desc)
          expect(query.to_query_string).to eq "sort=created_at%2C-score"
        end

        it 'creates a comma separated list' do
          query = Munson::Query.new.sort(:created_at, score: :desc, foo: :desc)
          expect(query.to_query_string).to eq "sort=created_at%2C-score%2C-foo"
        end
      end

      context 'given an invalid sort direction' do
        it 'raises an exception' do
          expect{ Munson::Query.new.sort(foo: :boom) }.
            to raise_error Munson::UnsupportedSortDirectionError
        end
      end

      context 'given a hash and a symbol' do
        it 'creates a comma separated list' do
          query = Munson::Query.new.sort({score: :desc}, :created_at)
          expect(query.to_query_string).to eq "sort=-score%2Ccreated_at"
        end
      end

      context 'given a hash' do
        it 'creates a comma separated list' do
          query = Munson::Query.new.sort(age: :asc, created_at: :desc)
          expect(query.to_query_string).to eq "sort=age%2C-created_at"
        end
      end

      context 'multiple calls' do
        it 'creates a comma separated list' do
          query = Munson::Query.new.sort(age: :asc).sort(created_at: :desc)
          expect(query.to_query_string).to eq "sort=age%2C-created_at"
        end
      end
    end

    describe ':include' do
      it "creates a comma seperated list of relations" do
        query = Munson::Query.new.include(:user, "profile.image")
        expect(query.to_query_string).to eq "include=profile.image%2Cuser"
      end

      context 'multiple calls' do
        it "creates a comma seperated list of relations" do
          query = Munson::Query.new.include(:user).include(:products)
          expect(query.to_query_string).to eq "include=products%2Cuser"
        end
      end
    end
  end

  describe '#filter' do
    it 'sets the filter options' do
      query = Munson::Query.new
      query.filter(age: 30)

      expect(query.values[:filter]).to include(age: 30)
    end

    context 'multiple calls' do
      it 'appends the filter options' do
        query = Munson::Query.new
        query.filter(age: 30).filter(gender: :male)

        expect(query.values[:filter]).to match([{age: 30}, {gender: :male}])
      end
    end
  end

  describe '#sort' do
    it 'sets the sort options' do
      query = Munson::Query.new
      query.sort(:age, :created_at)

      expect(query.values[:sort]).to include(:age, :created_at)
    end

    context 'multiple calls' do
      it 'appends the sort options' do
        query = Munson::Query.new
        query.sort(:age).sort(created_at: :desc)

        expect(query.values[:sort]).to match([:age, {created_at: :desc}])
      end
    end
  end

  describe '#fields' do
    it 'sets the fields options' do
      query = Munson::Query.new
      query.fields(users: %w(first_name last_name), address: :zip_code)

      expect(query.values[:fields]).
        to include(users: %w(first_name last_name), address: :zip_code)
    end

    context 'multiple calls' do
      it 'appends the fields options' do
        query = Munson::Query.new
        query.
          fields(user: [:first_name]).
          fields(address: :zip_code)

        expect(query.values[:fields]).
          to include({user: [:first_name]}, {address: :zip_code})
      end
    end
  end

  describe '#includes' do
    it 'sets the includes options' do
      query = Munson::Query.new
      query.include(:user, 'user.addresses')
      expect(query.values[:include]).to match([:user, 'user.addresses'])
    end

    context 'multiple calls' do
      it 'appends the includes options' do
        query = Munson::Query.new
        query.include(:user).include('user.addresses')
        expect(query.values[:include]).to match([:user, 'user.addresses'])
      end
    end
  end
end
