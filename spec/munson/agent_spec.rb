require 'spec_helper'

describe Munson::Agent do
  before{ Munson.configure url: 'http://api.example.com' }

  describe '#response_mapper' do
    pending 'setting a custom response mapper'
    pending 'build custom response mapper for Munson::Model to handle relations'
  end

  pending '#post'
  pending '#delete'
  pending '#put'

  pending "setting :route_format" #when converting types to paths

  # Should this setting be responsible for just formatting data to be sent, or
  # should it be responsible for casting responses' keys
  pending "setting :json_key_format"

  describe '#find' do
    it 'returns the parsed response' do
      spawn_agent("Article")
      stub_json_get("http://api.example.com/articles/1", :article_1)

      response = Article.munson.find(1)
      expect(response).to eq response_data(:article_1)
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
