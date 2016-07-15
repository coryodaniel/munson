require 'spec_helper'

describe Munson::Resource do
  before{ Munson.configure url: 'http://api.example.com' }

  describe '.register_munson_type' do
    it 'registers the type w/ Munson' do
      spawn_resource 'Article', type: :articles

      expect{ Article.register_munson_type :posts }.
        to change{ Munson.lookup_type(:posts) }.from(nil).to(Article)
    end

    it 'sets the agents type' do
      spawn_resource 'Article', type: :articles

      expect{ Article.register_munson_type :posts }.
        to change{ Article.munson.type }.from(:articles).to(:posts)
    end
  end



  describe 'query builder + find' do
    # Article.includes(:user).fields(user: [:id]).find(article_id)
    # Should querybuilder know about find?
    # Maybe create a Request object that encapsulates the query builder and exposes find as an alias for its "call" method...
  end

  describe '.relationship' do
    describe 'identity mapper?'
    # adds accessor methods, if a class type is provided, maps to that type class, else puts a hash in that key
    # has_many :posts #=> {}
    # has_many :posts, resource: Post #=> Post instance
    pending 'with munson resources'
  end

  describe '#find' do
    it 'returns the resource' do
      stub_json_get("http://api.example.com/articles/1", :article_1)
      spawn_resource 'Article', type: :articles

      resource = Article.find(1)
      expect(resource).to be_an(Article)
    end
  end

  describe '#id' do
    it 'returns the resource ID' do
      stub_json_get("http://api.example.com/articles/1", :article_1)
      spawn_resource 'Article', type: :articles

      resource = Article.find(1)
      expect(resource.id).to eq "1"
    end
  end

  describe '#includes' do
    it 'returns a QueryBuilder' do
      spawn_resource 'Article', type: :articles

      query = Article.includes(:author)
      expect(query).to be_a Munson::QueryBuilder
    end
  end

  describe '#page' do
    it 'returns a QueryBuilder' do
      spawn_resource 'Article', type: :articles
      Article.munson.paginator = :offset

      query = Article.page(limit: 100)
      expect(query).to be_a Munson::QueryBuilder
    end
  end

  describe '#filter' do
    it 'returns a QueryBuilder' do
      spawn_resource 'Article', type: :articles

      query = Article.filter(category: 'kittens')
      expect(query).to be_a Munson::QueryBuilder
    end
  end

  describe '#sort' do
    it 'returns a QueryBuilder' do
      spawn_resource 'Article', type: :articles

      query = Article.sort(:title)
      expect(query).to be_a Munson::QueryBuilder
    end
  end

  describe '.munson.connection=' do
    it 'overrides to the default connection' do
      spawn_resource 'Bar', type: :bars
      new_connection = Munson::Connection.new url: 'https://example.com/api'
      expect{ Bar.munson.connection = new_connection }.
        to change{ Bar.munson.connection }.
        from(Munson.default_connection).
        to(new_connection)
    end

    it "does not change other connections' path" do
      spawn_resource 'Foo', type: :foos
      spawn_resource 'Qux', type: :qeex
      new_connection = Munson::Connection.new url: 'https://example.com/api'
      expect{ Foo.munson.connection = new_connection }.
        to_not change{ Qux.munson.connection }.
        from(Munson.default_connection)
    end
  end

  describe '.munson.connection' do
    it 'defaults to the default connection' do
      spawn_resource 'Foo', type: :foos
      expect(Foo.munson.connection).to be Munson.default_connection
    end
  end
end
