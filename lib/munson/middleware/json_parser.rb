module Munson
  module Middleware
    class JsonParser < Faraday::Middleware
      def call(env)
        @app.call(env).on_complete do |env|
          env[:raw_body] = env[:body]
          env[:body] = parse(env[:body])
        end
      end

      private

      def parse(body)
        unless body.strip.empty?
          ::JSON.parse(body)
        else
          {}
        end
      end
    end
  end
end
