module Munson
  module Middleware
    class JsonParser < Faraday::Middleware
      def call(request_env)
        @app.call(request_env).on_complete do |response_env|
          response_env[:raw_body] = response_env[:body]
          response_env[:body] = parse(response_env[:body])
        end
      end

      private

      def parse(body)
        unless body.strip.empty?
          ::JSON.parse(body, symbolize_names: true)
        else
          {}
        end
      end
    end
  end
end
