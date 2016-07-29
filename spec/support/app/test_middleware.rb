class TestMiddleware < Faraday::Middleware
  def call(env)
    @app.call(env)
  end
end
