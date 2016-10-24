require 'spec_helper'

describe Munson::Client do
  it{ should have_attr_accessor(:path) }
  it{ should have_attr_accessor(:type) }

  describe '.query_builder=' do
    it 'sets the query builder class' do
      client = Munson::Client.new

      expect{ client.query_builder = CustomQueryBuilder }
        .to change{ client.query.class }
        .from(Munson::Query)
        .to(CustomQueryBuilder)
    end
  end

  describe '.query' do
    it 'returns a Munson::Query' do
      client = Munson::Client.new
      expect(client.query).to be_kind_of(Munson::Query)
    end
  end

  describe '.configure' do
    it "accepts block configuration" do
      client = Munson::Client.new.configure {|c| c.type = :kittens}
      expect(client.type).to eq :kittens
    end
  end

  describe '.path' do
    it 'defaults to the type' do
      client = Munson::Client.new.configure {|c| c.type = :kittens}
      expect(client.path).to eq 'kittens'
    end
  end

  describe "#connection" do
    it 'clones the Munson.default_connection' do
      Munson.configure url: 'http://example.com/api/v2'
      connection = Munson::Client.new.connection

      expect(connection.url).to eq "http://example.com/api/v2"
      expect(connection).to_not eq Munson.default_connection
    end
  end

  describe "#connection=" do
    it 'sets the connection' do
      client = Munson::Client.new
      connection = Munson::Connection.new({})

      expect{ client.connection = connection }
        .to change(client, :connection)
        .to(connection)
    end
  end
end
