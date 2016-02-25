require 'spec_helper'

describe Munson::QueryBuilder do
  describe '#initialize' do
    context 'when given an agent' do
      it 'sets the agent' do
        agent = double('Munson::Agent')
        query_builder = Munson::QueryBuilder.new(agent: agent)

        expect(query_builder.agent).to be agent
      end
    end
  end

  describe '#fetch' do
    it 'returns a collection' do
      Munson.configure url: 'http://api.example.com'
      spawn_agent("Article")
      Munson.register_type("articles", Article)
      stub_json_get("http://api.example.com/articles?include=author", :articles_with_author)

      query_builder = Article.munson.includes('author')
      expect(query_builder.fetch).to be_a Munson::Collection
    end
  end

  describe '#to_query_string' do
    describe 'doing all the things' do
      it 'generates a query string' do
        query_builder = Munson::QueryBuilder.
          filter(state: 'read').sort(received_at: :desc).
          fields(email: :subject).includes(:sender)

        expect(query_builder.to_query_string)
          .to eq("fields%5Bemail%5D=subject&filter%5Bstate%5D=read&include=sender&sort=-received_at")
      end
    end

    describe ':filter' do
      it 'returns a shallow hash' do
        query_builder = Munson::QueryBuilder.filter(state: 'read').filter(state: 'unread')
        expect(query_builder.to_query_string).to eq "filter%5Bstate%5D=read%2Cunread"
      end

      it 'returns a shallow hash' do
        query_builder = Munson::QueryBuilder.filter(min_age: 30, max_age: 65)
        expect(query_builder.to_query_string).to eq "filter%5Bmax_age%5D=65&filter%5Bmin_age%5D=30"
      end

      it 'returns a shallow hash' do
        query_builder = Munson::QueryBuilder.filter(min_age: 30).filter(max_age: 65)
        expect(query_builder.to_query_string).to eq "filter%5Bmax_age%5D=65&filter%5Bmin_age%5D=30"
      end
    end

    describe ':fields' do
      context 'given a hash of symbols and arrays' do
        it '' do
          query_builder = Munson::QueryBuilder.fields(users: [:first_name])
          expect(query_builder.to_query_string).to eq "fields%5Busers%5D=first_name"
        end
      end

      context 'given a hash of symbols and symbols' do
        it 'wraps the symbol in an array' do
          query_builder = Munson::QueryBuilder.fields(users: :first_name).fields(addresses: :postal_code)
          expect(query_builder.to_query_string).to eq "fields%5Baddresses%5D=postal_code&fields%5Busers%5D=first_name"
        end
      end

      context 'given multiple hashes' do
        it 'merges the hashes' do
          query_builder = Munson::QueryBuilder.fields(users: [:first_name, :last_name], addresses: :postal_code)
          expect(query_builder.to_query_string).to eq "fields%5Baddresses%5D=postal_code&fields%5Busers%5D=first_name%2Clast_name"
        end
      end
    end

    describe ':sort' do
      context 'given a symbol and a hash' do
        it 'creates a comma separated list' do
          query_builder = Munson::QueryBuilder.sort(:created_at, score: :desc)
          expect(query_builder.to_query_string).to eq "sort=created_at%2C-score"
        end

        it 'creates a comma separated list' do
          query_builder = Munson::QueryBuilder.sort(:created_at, score: :desc, foo: :desc)
          expect(query_builder.to_query_string).to eq "sort=created_at%2C-score%2C-foo"
        end
      end

      context 'given an invalid sort direction' do
        it 'raises an exception' do
          expect{ Munson::QueryBuilder.sort(foo: :boom) }.
            to raise_error Munson::QueryBuilder::UnsupportedSortDirectionError
        end
      end

      context 'given a hash and a symbol' do
        it 'creates a comma separated list' do
          query_builder = Munson::QueryBuilder.sort({score: :desc}, :created_at)
          expect(query_builder.to_query_string).to eq "sort=-score%2Ccreated_at"
        end
      end

      context 'given a hash' do
        it 'creates a comma separated list' do
          query_builder = Munson::QueryBuilder.sort(age: :asc, created_at: :desc)
          expect(query_builder.to_query_string).to eq "sort=age%2C-created_at"
        end
      end

      context 'multiple calls' do
        it 'creates a comma separated list' do
          query_builder = Munson::QueryBuilder.sort(age: :asc).sort(created_at: :desc)
          expect(query_builder.to_query_string).to eq "sort=age%2C-created_at"
        end
      end
    end

    describe ':include' do
      it "creates a comma seperated list of relations" do
        query_builder = Munson::QueryBuilder.includes(:user, "profile.image")
        expect(query_builder.to_query_string).to eq "include=profile.image%2Cuser"
      end

      context 'multiple calls' do
        it "creates a comma seperated list of relations" do
          query_builder = Munson::QueryBuilder.includes(:user).includes(:products)
          expect(query_builder.to_query_string).to eq "include=products%2Cuser"
        end
      end
    end
  end

  describe '#filter' do
    it 'sets the filter options' do
      query_builder = Munson::QueryBuilder.new
      query_builder.filter(age: 30)

      expect(query_builder.query[:filter]).to include(age: 30)
    end

    context 'multiple calls' do
      it 'appends the filter options' do
        query_builder = Munson::QueryBuilder.new
        query_builder.filter(age: 30).filter(gender: :male)

        expect(query_builder.query[:filter]).to match([{age: 30}, {gender: :male}])
      end
    end
  end

  describe '#sort' do
    it 'sets the sort options' do
      query_builder = Munson::QueryBuilder.new
      query_builder.sort(:age, :created_at)

      expect(query_builder.query[:sort]).to include(:age, :created_at)
    end

    context 'multiple calls' do
      it 'appends the sort options' do
        query_builder = Munson::QueryBuilder.new
        query_builder.sort(:age).sort(created_at: :desc)

        expect(query_builder.query[:sort]).to match([:age, {created_at: :desc}])
      end
    end
  end

  describe '#fields' do
    it 'sets the fields options' do
      query_builder = Munson::QueryBuilder.new
      query_builder.fields(users: %w(first_name last_name), address: :zip_code)

      expect(query_builder.query[:fields]).
        to include(users: %w(first_name last_name), address: :zip_code)
    end

    context 'multiple calls' do
      it 'appends the fields options' do
        query_builder = Munson::QueryBuilder.new
        query_builder.
          fields(user: [:first_name]).
          fields(address: :zip_code)

        expect(query_builder.query[:fields]).
          to include({user: [:first_name]}, {address: :zip_code})
      end
    end
  end

  describe '#includes' do
    it 'sets the includes options' do
      query_builder = Munson::QueryBuilder.new
      query_builder.includes(:user, 'user.addresses')
      expect(query_builder.query[:include]).to match([:user, 'user.addresses'])
    end

    context 'multiple calls' do
      it 'appends the includes options' do
        query_builder = Munson::QueryBuilder.new
        query_builder.includes(:user).includes('user.addresses')
        expect(query_builder.query[:include]).to match([:user, 'user.addresses'])
      end
    end
  end

  describe '.fields' do
    it 'returns an instance' do
      query_builder = Munson::QueryBuilder.fields(user: [:first_name, :last_name])

      expect(query_builder).to be_a Munson::QueryBuilder
    end

    it 'calls #fields on the instance' do
      query_builder = Munson::QueryBuilder.fields(user: [:first_name, :last_name])

      expect(query_builder.query[:fields]).to include(user: [:first_name, :last_name])
    end
  end

  describe '.includes' do
    it 'returns an instance' do
      query_builder = Munson::QueryBuilder.includes(:user, 'user.addresses')

      expect(query_builder).to be_a Munson::QueryBuilder
    end

    it 'calls #includes on the instance' do
      query_builder = Munson::QueryBuilder.includes(:user, 'user.addresses')

      expect(query_builder.query[:include]).to match([:user, 'user.addresses'])
    end
  end

  describe '.filter' do
    it 'returns an instance' do
      query_builder = Munson::QueryBuilder.filter(age: 30)

      expect(query_builder).to be_a Munson::QueryBuilder
    end

    it 'calls #filter on the instance' do
      query_builder = Munson::QueryBuilder.filter(age: 30)

      expect(query_builder.query[:filter]).to include(age: 30)
    end
  end

  describe '.sort' do
    it 'returns an instance' do
      query_builder = Munson::QueryBuilder.filter(age: 30)

      expect(query_builder).to be_a Munson::QueryBuilder
    end

    it 'calls #sort on the instance' do
      query_builder = Munson::QueryBuilder.sort(:age)

      expect(query_builder.query[:sort]).to include(:age)
    end
  end

  describe '#page' do
    context 'when a paginator is not set' do
      it 'raises an exception' do
        query_builder = Munson::QueryBuilder.new
        expect{ query_builder.page }.
          to raise_error Munson::QueryBuilder::PaginatorNotSet
      end
    end

    context 'when a paginator has been set' do
      it 'returns the chainable query builder' do
        pager = double('paginator')
        allow(pager).to receive(:set)

        query_builder = Munson::QueryBuilder.new paginator: pager
        expect(query_builder.page(limit: 3)).to eq query_builder
      end
    end
  end

  describe '#to_params' do
    context 'when paginating' do
      it 'includes :page hash' do
        query_builder = Munson::QueryBuilder.new paginator: Munson::Paginator::OffsetPaginator.new
        query_builder.page(limit: 10, offset: 3).includes('user')

        expect(query_builder.to_params).to eq({
          include: 'user',
          page: {limit: 10, offset: 3}
        })
      end
    end
  end
end
