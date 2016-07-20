$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require "codeclimate-test-reporter"
CodeClimate::TestReporter.start
require 'webmock/rspec'
require 'pry-byebug'

require 'munson'

require 'support/macros/json_api_document_macros'
require 'support/matchers/have_attr_accessor'
require 'support/matchers/have_data'

Munson.configure url: 'http://api.example.com'
Dir["spec/support/app/*"].each{ |f| load f }

WebMock.disable_net_connect!(allow: "codeclimate.com")
RSpec.configure do |c|
  c.include Munson::RSpec::Macros::JsonApiDocumentMacros
  c.before(:each) do
    Munson.configure url: 'http://api.example.com'
    stub_json_get("http://api.example.com/artists", :artists)
    stub_json_get("http://api.example.com/artists/9?include=albums", :artist_9_include_albums)
    stub_json_get("http://api.example.com/artists/9?include=members", :artist_9_include_members)
    stub_json_get("http://api.example.com/artists/9?include=albums,record_label", :artist_9_include_albums_record_label)
    stub_json_get("http://api.example.com/artists/9", :artist_9)
    stub_json_get("http://api.example.com/venues/1", :venue_1)
    stub_json_get("http://api.example.com/venues", :venues)
    stub_json_get("http://api.example.com/albums/1", :album_1)
    stub_json_get("http://api.example.com/albums", :albums)
    stub_json_get("http://api.example.com/albums?include=artist", :albums_include_artist)
    stub_json_get("http://api.example.com/albums/1?include=artist", :album_1_include_artist)
    stub_json_get("http://api.example.com/albums/1?include=songs", :album_1_include_songs)
    stub_json_get("http://api.example.com/articles?include=author", :articles_include_author)
    stub_json_get("http://api.example.com/articles?include=author,comments", :articles_include_author_comments)
  end
end
