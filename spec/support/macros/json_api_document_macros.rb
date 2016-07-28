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
      end
    end
  end
end
