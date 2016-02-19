require 'spec_helper'

describe Munson::Agent do
  before{ Munson.configure url: 'http://api.example.com' }

  describe '#find' do
    it 'returns the parsed response' do
      stub_json_get("http://api.example.com/articles/1", :article_1)
      response = Article.munson.find(1)
      expect(response).to have_data(:article_1)
    end

    context 'when passing an array of IDs' do
      it 'returns the parsed response' do
        stub_json_get("http://api.example.com/articles/1", :article_1)
        stub_json_get("http://api.example.com/articles/2", :article_2)

        response = Article.munson.find(1,2)
        expect(response.first).to have_data(:article_1)
        expect(response.last).to have_data(:article_2)
      end
    end
  end

  describe '#get' do
    it 'returns the parsed response' do
      stub_json_get("http://api.example.com/articles", :articles)

      response = Article.munson.get
      expect(response).to have_data(:articles)
    end

    context 'when using a query' do
      it 'returns the parsed response' do
        stub_json_get("http://api.example.com/articles?include=author", :articles_with_author)

        query    = Article.munson.query.includes('author').to_params
        response = Article.munson.get(params: query)
        expect(response).to have_data(:articles_with_author)
      end
    end
  end

  pending "attr_accessor :paginator"

  pending "attr_accessor :wrapper_thingy" # proc applied to response.body, defaults to return response
  pending 'wrapping a collection vs a single item'



  pending '#post'
  pending '#delete'
  pending '#put'

  pending 'getting a resource'
  pending 'getting resources'

  pending "attr_accessor :route_format"
  pending "attr_accessor :json_key_format"
  pending "attr_accessor :query_builder"
  pending "attr_accessor :default_page_size = 10"
  pending "attr_accessor :maximum_page_size = 20"
end
