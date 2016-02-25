require 'spec_helper'

describe Munson::Resource do
  before{ Munson.configure url: 'http://api.example.com' }

  describe '#find' do
    it 'returns the resource' do
      stub_json_get("http://api.example.com/articles/1", :article_1)
      spawn_model 'Article'

      resources = Article.find(1)
      expect(resources).to have_data(:article_1)
    end
  end

  describe '#includes' do
    it 'returns a QueryBuilder' do
      spawn_model 'Article'

      query = Article.includes(:author)
      expect(query).to be_a Munson::QueryBuilder
    end
  end

  describe '#page' do
    it 'returns a QueryBuilder' do
      spawn_model 'Article'
      Article.munson.paginator = :offset

      query = Article.page(limit: 100)
      expect(query).to be_a Munson::QueryBuilder
    end
  end

  describe '#filter' do
    it 'returns a QueryBuilder' do
      spawn_model 'Article'

      query = Article.filter(category: 'kittens')
      expect(query).to be_a Munson::QueryBuilder
    end
  end

  describe '#sort' do
    it 'returns a QueryBuilder' do
      spawn_model 'Article'

      query = Article.sort(:title)
      expect(query).to be_a Munson::QueryBuilder
    end
  end

  describe '.munson.connection=' do
    it 'overrides to the default connection' do
      spawn_model 'Bar'
      new_connection = Munson::Connection.new url: 'https://example.com/api'
      expect{ Bar.munson.connection = new_connection }.
        to change{ Bar.munson.connection }.
        from(Munson.default_connection).
        to(new_connection)
    end

    it "does not change other connections' path" do
      spawn_model 'Baz'
      spawn_model 'Qux'
      new_connection = Munson::Connection.new url: 'https://example.com/api'
      expect{ Baz.munson.connection = new_connection }.
        to_not change{ Qux.munson.connection }.
        from(Munson.default_connection)
    end
  end

  describe '.path' do
    it 'defaults to the class name' do
      spawn_model 'Pickle'
      expect(Pickle.munson.path).to eql('pickles')
    end

    it 'sets the JSON API type' do
      spawn_model 'Quux'
      expect{ Quux.munson.path= :qeex }.
        to change{ Quux.munson.path }.
        from('quuxes').to(:qeex)
    end
  end

  describe '.munson.connection' do
    it 'defaults to the default connection' do
      spawn_model 'Foo'
      expect(Foo.munson.connection).to be Munson.default_connection
    end
  end
end
