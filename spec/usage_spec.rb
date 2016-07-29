require 'spec_helper'

RSpec.describe 'Usage' do
  it 'initialize side loaded resources' do
    stub_api_request(:articles_include_author_comments)

    articles = Article.include(:author, :comments).fetch
    author = articles.first.author
    expect(author).to be_a(Person)

    article = articles.first
    comment = article.comments.first
    expect(comment).to be_a(Comment)

    expect(comment.author).to eq(author) # this was loaded, because it HAPPENED to be the article author
  end

  it 'knows if a resource has been persisted' do
    stub_api_request(:articles_include_author_comments)

    articles = Article.include(:author, :comments).fetch
    expect(articles.first).to be_persisted
  end

  it 'casts attribute values from JSON' do
    stub_api_request(:articles_include_author_comments)

    articles = Article.include(:author, :comments).fetch
    comment = articles.first.comments.first
    expect(comment.mentions).to eq %w(paulbunyan)

    last_comment = articles.first.comments.last
    expect(last_comment.mentions).to eq []
  end

  it 'can update resources' do
    stub_api_request(:articles_include_author_comments)

    articles = Article.include(:author, :comments).fetch
    author = articles.first.author
    author.first_name = "Tomas"
    author.last_name = "Blunderbee"
    author.twitter = "blunderz"
    expect(author.first_name).to eq 'Tomas'

    json = {
      data: {
        type: :people,
        id: author.id.to_s,
        attributes: {
          "first-name" => "Tomas",
          "last-name" => "Blunderbee",
          "twitter" => "blunderz"
        }
      }
    }

    stub = stub_request(:patch, "http://api.example.com/people/#{author.id}").
      with(body: JSON.dump(json)).
      to_return(status: 200, body: JSON.dump(json))

    expect(author.save).to be true
  end

  it "can load unloaded relationships" do
    pending
    stub_api_request(:articles_include_author_comments)

    articles = Article.include(:author, :comments).fetch
    last_comment = articles.first.comments.last

    expect(last_comment.author) # This wasn't loaded... shouldn't explode
  end

  it 'can force a reload of a relationship' do
    pending
    stub_api_request(:articles_include_author_comments)

    articles = Article.include(:author, :comments).fetch
    article = articles.first

    comment = article.comments(true).first #should force reload of comments
  end

  describe 'Artist (Munson::Resource)' do
    it 'loads other munson resources' do
      stub_api_request(:artist_9_include_albums)

      artist = Artist.include(:albums).find(9)
      expect(artist).to be_a(Artist)
      expect(artist.albums.first).to be_a(Album)
    end

    it 'loads other registered resources' do
      stub_api_request(:artists)
      artists = Artist.fetch
      expect(artists).to be_a(Munson::Collection)
    end

    it 'loads unregistered JSONAPI resources' do
      stub_api_request(:artist_9_include_albums_record_label)
      artist = Artist.include(:albums,:record_label).find(9)
      expect(artist.record_label).to be_a(Munson::Document)
      expect(artist.record_label[:name]).to eq "Capitol Records"
    end
  end

  describe 'Album (non-resource)' do
    it "initializes a Munson::Collectin of albums" do
      stub_api_request(:albums)

      albums = Album.munson.fetch
      first_album = albums.first

      expect(albums).to be_a(Munson::Collection)
      expect(first_album).to be_a(Album)
      expect(first_album.title).to eq "The Crane Wife"
    end

    it "finds records by ID" do
      stub_api_request(:album_1_include_artist)
      album = Album.munson.include(:artist).find(1)
      expect(album).to be_a(Album)
      expect(album.title).to eq "The Crane Wife"
    end
  end

  describe 'Venues (unregistered, non-resource)' do
    it "returns Munson::Documents if the class is unregistered" do
      stub_api_request(:venues)
      venues = Venue.munson.fetch
      expect(venues).to be_a(Munson::Collection)
      expect(venues.first).to be_a(Munson::Document)
    end
  end
end
