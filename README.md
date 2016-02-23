# Munson

A JSON API Spec client for Ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'munson'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install munson

## Usage

### Munson::Connection and configuring the default connection

Munson is designed to support multiple connections or API endpoints. A connection is a wrapper around Faraday::Connection that includes a few pieces of middleware for parsing and encoding requests and responses to JSON API Spec.

```ruby
Munson.configure(url: 'http://api.example.com') do |c|
  c.use MyCustomMiddleware
end

Options can be any [Faraday::Connection options](https://github.com/lostisland/faraday/blob/master/lib/faraday/connection.rb Faraday::Connection)
```

Additional connections can be created with:
```ruby
my_connection = Munson::Connection.new(url: 'http://api2.example.com') do |c|
  c.use MoreMiddleware
  c.use AllTheMiddlewares
end
```

### Munson::Agent

A munson agent uses a connection (by default, Munson.default_connection) to make and parse requests
while allowing additional configuration for a particular resource.

```ruby
Munson.configure url: 'http://api.example.com'

class Article  
  def self.munson
    return @munson if @munson
    @munson = Munson::Agent.new(
      connection: Munson.default_connection || YOU_COULD_BUILD_YOUR_OWN
      path: 'articles'
    )
  end
end
```

#### Fetching a single record
#### Filtering
#### Sorting
#### Including (Side loading related resources)
#### Sparse Fieldsets
#### Paginating

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/coryodaniel/munson.
