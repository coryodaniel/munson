
require 'spec_helper'

describe Munson::ResponseMapper do
  before{ Munson.configure url: 'http://api.example.com' }

  describe '#initialize' do
    describe 'when the type is registered' do
      context 'when getting a single resource' do
        it 'returns a "model"' do
          spawn_agent("Article", type: :articles)
          Munson.register_type("articles", Article)
          stub_json_get("http://api.example.com/articles/1", :article_1)

          response = Article.munson.get path: 'articles/1'
          mapper = Munson::ResponseMapper.new(response)
          expect(mapper.resource).to be_an(Article)
        end
      end

      it 'returns a collection of models' do
        spawn_agent("Article", type: :articles)
        Munson.register_type("articles", Article)
        stub_json_get("http://api.example.com/articles", :articles)

        response = Article.munson.get
        mapper = Munson::ResponseMapper.new(response)

        expect(mapper.resources.first).to be_an(Article)
      end
    end

    context 'when the type is not registered' do
      context 'when getting a single resource' do
        it 'returns a hash' do
          spawn_agent("Article", type: :articles)
          stub_json_get("http://api.example.com/articles/1", :article_1)

          response = Article.munson.get path: 'articles/1'
          resource = Munson::ResponseMapper.new(response).resource

          expect(resource).to match(response_json(:article_1))
        end
      end

      it 'returns a collection hashes' do
        spawn_agent("Article", type: :articles)
        stub_json_get("http://api.example.com/articles?include=author", :articles_with_author)

        query    = Article.munson.includes('author').to_params
        response = Article.munson.get(params: query)

        resources = Munson::ResponseMapper.new(response).resources
        expect(resources).to be_kind_of(Munson::Collection)
        expect(resources.first).to include(:data, :included)
      end
    end
  end
end
