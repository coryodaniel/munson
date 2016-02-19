require 'spec_helper'

describe Munson::Resource do
  pending 'package response in Active::Model'
  pending 'adding custom member routes'
  pending 'adding custom collection routes'

  describe '.munson.connection' do
    it 'defaults to the default connection' do
      spawn_model 'Foo'
      expect(Foo.munson.connection).to be Munson.default_connection
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
end
