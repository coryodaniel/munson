require 'spec_helper'

describe Munson::Agent do
  before{ Munson.configure url: 'http://api.example.com' }

  describe "resource processing middleware" do
    context 'when no processing middleware is set' do
      it 'returns the JSON parsed response' do
        spawn_agent("Article")
        stub_json_get("http://api.example.com/articles/1", :article_1)
        response = Article.munson.find(1)
        expect(response).to have_data(:article_1)
      end
    end

    context 'data processor' do
      it '' do
        spawn_agent("Article")
        class Article
          def initialize(*)
          end
        end

        class ArticleWrapper < Faraday::Middleware
          def call(env)
            @app.call(env).on_complete do |response_env|
              response_env[:resources] = response_env.body[:data].map do |article|
                Article.new(article[:attributes])
              end
            end
          end
        end

        Munson.configure url: 'http://api.example.com' do |c|
          c.use ArticleWrapper
        end

        stub_json_get("http://api.example.com/articles?include=author", :articles_with_author)

        query    = Article.munson.includes('author').to_params
        resources = Article.munson.get(params: query).env[:resources]

        expect(resources.first).to be_a(Article)
      end
    end
  end

  pending '#post'
  pending '#delete'
  pending '#put'

  pending "setting :route_format"
  pending "setting :json_key_format"

  describe '#find' do
    it 'returns the parsed response' do
      spawn_agent("Article")
      stub_json_get("http://api.example.com/articles/1", :article_1)
      response = Article.munson.find(1)
      expect(response).to have_data(:article_1)
    end

    context 'when passing an array of IDs' do
      it 'returns the parsed response' do
        spawn_agent("Article")
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
      spawn_agent("Article")
      stub_json_get("http://api.example.com/articles", :articles)

      response = Article.munson.get
      expect(response).to have_data(:articles)
    end

    context 'when using a query' do
      it 'returns the parsed response' do
        spawn_agent("Article")
        stub_json_get("http://api.example.com/articles?include=author", :articles_with_author)

        query    = Article.munson.includes('author').to_params
        response = Article.munson.get(params: query)
        expect(response).to have_data(:articles_with_author)
      end
    end
  end

  describe 'pagination DSL' do
    describe "#paginator=" do
      context 'setting by name' do
        it 'sets the paginator' do
          agent = Munson::Agent.new(paginator: :offset)
          expect(agent.paginator).to be Munson::Paginator::OffsetPaginator
        end
      end

      context 'setting a custom paginator' do
        it 'sets the paginator' do
          class KewlPager;end;
          agent = Munson::Agent.new(paginator: KewlPager)
          expect(agent.paginator).to be KewlPager
        end
      end
    end

    describe "#paginator_options" do
      it 'sets the paginator_options' do
        agent = Munson::Agent.new(paginator_options: {max_limit: 100, default_limit: 10})
        expect(agent.paginator_options).to eq({max_limit: 100, default_limit: 10})
      end
    end

    describe '#query' do
      it 'instantiates a pager and passes it to the query builder' do
        agent = Munson::Agent.new paginator: :offset

        expect agent.query.paging?
      end
    end
  end

  describe '#query' do
    it 'returns a new query builder instance' do
      agent = Munson::Agent.new

      expect(agent.query).to be_a Munson::QueryBuilder
      expect(agent.query).to_not be(agent.query)
    end
  end
end
