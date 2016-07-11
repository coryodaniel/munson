require 'spec_helper'

describe Munson::ResponseMapper do
  before{ Munson.configure url: 'http://api.example.com' }

  describe '#initialize' do
    pending 'when side-loading resources'

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
          mapper = Munson::ResponseMapper.new(response)
          expect(mapper.resource).to match(response_json(:article_1)[:data])
        end
      end

      it 'returns a hashes' do
        spawn_agent("Article", type: :articles)
        stub_json_get("http://api.example.com/articles", :articles)

        response = Article.munson.get
        mapper = Munson::ResponseMapper.new(response)

        expect(mapper.resources).to match(response_json(:articles)[:data])
      end
    end
  end
end
