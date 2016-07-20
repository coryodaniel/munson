module Munson
  module RSpec
    module Macros
      module JsonApiDocumentMacros
        def create_payload(type, attribs, id: nil, relationships: nil)
          object = {
            type: type,
            attributes: attribs
          }
          object[:id] = id if id
          { data: object }
        end

        def response_body(name)
          File.open("spec/support/responses/#{name}.json").read
        end

        def response_json(name)
          JSON.parse response_body(name), symbolize_names: true
        end

        def response_data(name)
          response_json(name)[:data]
        end

        def request_body(name)
          File.open("spec/support/requests/#{name}.json").read
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
