require 'spec_helper'

describe Munson::Agent do
  before{ Munson.configure url: 'http://api.example.com' }

  pending '#post'
  pending '#delete'
  pending '#put'
  pending '#patch'

  # Should this setting be responsible for just formatting data to be sent, or
  # should it be responsible for casting responses' keys
  pending "setting :json_key_format"
  pending "setting :route_format" #when converting types to paths

  describe '#default_path' do
    it 'defaults to the Agent#type' do
      spawn_agent("Article", type: :articles)
      expect(Article.munson.default_path).to eq '/articles'
    end
  end

  describe '#default_path=' do
    it 'sets the default path' do
      spawn_agent("Article", type: :articles)

      expect{ Article.munson.default_path = '/user/articles' }.
        to change(Article.munson, :default_path).
        from('/articles').to('/user/articles')
    end
  end

  describe '#initialize' do
    context 'when specifying the :path' do
      it 'sets the default_path' do
        agent = Munson::Agent.new(path: '/boo')
        expect(agent.default_path).to eq '/boo'
      end
    end
  end

  describe '#find' do
    it 'returns the parsed response' do
      spawn_agent("Article", type: :articles)
      stub_json_get("http://api.example.com/articles/1", :article_1)

      response = Article.munson.find(1)
      expect(response).to eq response_json(:article_1)
    end
  end

  describe '#get' do
    it 'returns the parsed response' do
      spawn_agent("Article", type: :articles)
      stub_json_get("http://api.example.com/articles", :articles)

      response = Article.munson.get
      expect(response).to have_data(:articles)
    end

    context 'when using a query' do
      it 'returns the parsed response' do
        spawn_agent("Article", type: :articles)
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
