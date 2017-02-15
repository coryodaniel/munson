module Munson
  module RSpec
    module Macros
      module StubRequestMacros
        def stub_api_request(document_name)
          request_map = {
            artists: "http://api.example.com/artists",
            artist_9_include_albums: "http://api.example.com/artists/9?include=albums",
            artist_9_include_members: "http://api.example.com/artists/9?include=members",
            artist_9_include_albums_record_label: "http://api.example.com/artists/9?include=albums,record_label",
            artist_9: "http://api.example.com/artists/9",
            venue_1: "http://api.example.com/venues/1",
            venues: "http://api.example.com/venues",
            album_1: "http://api.example.com/albums/1",
            albums: "http://api.example.com/albums",
            albums_include_artist: "http://api.example.com/albums?include=artist",
            albums_top_include_artist: "http://api.example.com/albums/top?include=artist",
            album_1_include_artist: "http://api.example.com/albums/1?include=artist",
            album_1_include_songs: "http://api.example.com/albums/1?include=songs",
            articles_include_author: "http://api.example.com/articles?include=author",
            articles_include_author_comments: "http://api.example.com/articles?include=author,comments"
          }
          stub_json_get(request_map[document_name], document_name)
        end

        def stub_json_get(url, document_name)
          stub_request(:get, url).
            with(
              headers: {
                'Accept'=>'application/vnd.api+json',
                'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                'User-Agent'=>"Munson v#{Munson::VERSION}"
              }
            ).to_return({
              body: response_body(document_name),
              headers: {'Content-Type'=>'application/vnd.api+json'}
            })
        end
      end
    end
  end
end
