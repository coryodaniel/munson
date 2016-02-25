# Munson

[![Code Climate](https://codeclimate.com/github/coryodaniel/munson/badges/gpa.svg)](https://codeclimate.com/github/coryodaniel/munson)
[![Test Coverage](https://codeclimate.com/github/coryodaniel/munson/badges/coverage.svg)](https://codeclimate.com/github/coryodaniel/munson/coverage)
![Build Status](https://travis-ci.org/coryodaniel/munson.svg?branch=master)

A JSON API Spec client for Ruby

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
```

Options can be any [Faraday::Connection options](https://github.com/lostisland/faraday/blob/master/lib/faraday/connection.rb Faraday::Connection)

Additional connections can be created with:
```ruby
my_connection = Munson::Connection.new(url: 'http://api2.example.com') do |c|
  c.use MoreMiddleware
  c.use AllTheMiddlewares
end
```

### Munson::Agent

Munson::Agent provides a small 'DSL' to build requests and parse responses,
while allowing additional configuration for a particular 'resource.'


```ruby
Munson.configure url: 'http://api.example.com'

class Product
  def self.munson
    return @munson if @munson
    @munson = Munson::Agent.new(
      connection: Munson.default_connection, # || Munson::Connection.new(...)
      paginator: :offset,
      path: 'products'
    )
  end
end
```

#### Getting the faraday response
```ruby
query = Product.munson.filter(min_price: 30, max_price: 65)
# its chainable
query.filter(category: 'Hats').filter(size: ['small', 'medium'])

query.to_params
#=> {:filter=>{:min_price=>"30", :max_price=>"65", :category=>"Hats", :size=>"small,medium"}}

Product.munson.get(params: query.to_params)
```

#### Filtering

```ruby
query = Product.munson.filter(min_price: 30, max_price: 65)
# its chainable
query.filter(category: 'Hats').filter(size: ['small', 'medium'])

query.to_params
#=> {:filter=>{:min_price=>"30", :max_price=>"65", :category=>"Hats", :size=>"small,medium"}}

query.fetch #=> Some lovely data
```

#### Sorting

```ruby
query = Product.munson.sort(created_at: :desc)
# its chainable
query.sort(:price) # defaults to ASC

query.to_params
#=> {:sort=>"-created_at,price"}

query.fetch #=> Some lovely data
```

#### Including (Side loading related resources)

```ruby
query = Product.munson.includes(:manufacturer)
# its chainable
query.includes(:vendor)

query.to_params
#=> {:include=>"manufacturer,vendor"}

query.fetch #=> Some lovely data
```

#### Sparse Fieldsets

```ruby
query = Product.munson.fields(products: [:name, :price])
# its chainable
query.includes(:manufacturer).fields(manufacturer: [:name])

query.to_params
#=> {:fields=>{:products=>"name,price", :manufacturer=>"name"}, :include=>"manufacturer"}

query.fetch #=> Some lovely data
```

#### All the things!
```ruby
query = Product.munson.
  filter(min_price: 30, max_price: 65).
  includes(:manufacturer).
  sort(popularity: :desc, price: :asc).
  fields(product: ['name', 'price'], manufacturer: ['name', 'website']).
  page(number: 1, limit: 100)

query.to_params
#=> {:filter=>{:min_price=>"30", :max_price=>"65"}, :fields=>{:product=>"name,price", :manufacturer=>"name,website"}, :include=>"manufacturer", :sort=>"-popularity,price", :page=>{:limit=>10}}

query.fetch #=> Some lovely data
```

#### Fetching a single resource

```ruby
Product.munson.find(1)
```

#### Paginating

A paged and offset paginator are included with Munson.

Using the ```offset``` paginator
```ruby
class Product
  def self.munson
    return @munson if @munson
    @munson = Munson::Agent.new(
      paginator: :offset,
      path: 'products'
    )
  end
end

query = Product.munson.includes('manufacturer').page(offset: 10, limit: 25)
query.to_params
# => {:include=>"manufacturer", :page=>{:limit=>10, :offset=>10}}

query.fetch #=> Some lovely data
```

Using the ```paged``` paginator
```ruby
class Product  
  def self.munson
    return @munson if @munson
    @munson = Munson::Agent.new(
      paginator: :paged,
      path: 'products'
    )
  end
end

query = Product.munson.includes('manufacturer').page(page: 10, size: 25)
query.to_params
# => {:include=>"manufacturer", :page=>{:page=>10, :size=>10}}

query.fetch #=> Some lovely data
```

##### Custom paginators
Since the JSON API Spec does not dictate [how to paginate](http://jsonapi.org/format/#fetching-pagination), Munson has been designed to make adding custom paginators pretty easy.

```ruby
class CustomPaginator
  # @param [Hash] Hash of options like max/default page size
  def initialize(opts={})
  end

  # @param [Hash] Hash to set the 'limit' and 'offset' to be returned later by #to_params
  def set(params={})
  end

  # @return [Hash] Params to be merged into query builder.
  def to_params
    { page: {} }
  end
end

```

### Munson::Resource

A munson resource provides a DSL in the including class for doing common JSON API queries on your ruby class.

It delegates a set of methods so that they dont have to be accessed through the ```munson``` class method and sets a few options based on the including class name.

It also will alter the response objects coming from #fetch and #find. Instead of returning a json hash like
when using the bare Munson::Agent, Munson::Resource will pass the JSON Spec attributes and the ID as a hash into your class's initializer.

```ruby
class Product
  include Munson::Resource
end

# Munson method is there, should you be looking for it.
Product.munson #=> Munson::Agent
```

Changing the type name:
```ruby
class Product
  include Munson::Resource
  munson.type = "things"
end
```

#### Filtering

```ruby
query = Product.filter(min_price: 30, max_price: 65)
# its chainable
query.filter(category: 'Hats').filter(size: ['small', 'medium'])

query.to_params
#=> {:filter=>{:min_price=>"30", :max_price=>"65", :category=>"Hats", :size=>"small,medium"}}

query.fetch #=> Munson::Collection<Product,Product>
```

#### Sorting

```ruby
query = Product.sort(created_at: :desc)
# its chainable
query.sort(:price) # defaults to ASC

query.to_params
#=> {:sort=>"-created_at,price"}

query.fetch #=> Munson::Collection<Product,Product>
```

#### Including (Side loading related resources)

```ruby
query = Product.includes(:manufacturer)
# its chainable
query.includes(:vendor)

query.to_params
#=> {:include=>"manufacturer,vendor"}

query.fetch #=> Munson::Collection<Product,Product>
```

#### Sparse Fieldsets

```ruby
query = Product.fields(products: [:name, :price])
# its chainable
query.includes(:manufacturer).fields(manufacturer: [:name])

query.to_params
#=> {:fields=>{:products=>"name,price", :manufacturer=>"name"}, :include=>"manufacturer"}

query.fetch #=> Munson::Collection<Product,Product>
```

#### All the things!
```ruby
query = Product.
  filter(min_price: 30, max_price: 65).
  includes(:manufacturer).
  sort(popularity: :desc, price: :asc).
  fields(product: ['name', 'price'], manufacturer: ['name', 'website']).
  page(number: 1, limit: 100)

query.to_params
#=> {:filter=>{:min_price=>"30", :max_price=>"65"}, :fields=>{:product=>"name,price", :manufacturer=>"name,website"}, :include=>"manufacturer", :sort=>"-popularity,price", :page=>{:limit=>10}}

query.fetch #=> Munson::Collection<Product,Product>
```

#### Fetching a single resource

```ruby
Product.find(1) #=> product
```

#### Paginating

A paged and offset paginator are included with Munson.

Using the ```offset``` paginator
```ruby
class Product
  include Munson::Resource
  munson.paginator = :offset
  munson.paginator_options = {default: 10, max: 100}
end

query = Product.includes('manufacturer').page(offset: 10, limit: 25)
query.to_params
# => {:include=>"manufacturer", :page=>{:limit=>10, :offset=>10}}

query.fetch #=> Munson::Collection<Product,Product>
```

Using the ```paged``` paginator
```ruby
class Product
  include Munson::Resource
  munson.paginator = :paged
  munson.paginator_options = {default: 10, max: 100}
end

query = Product.includes('manufacturer').page(page: 10, size: 25)
query.to_params
# => {:include=>"manufacturer", :page=>{:page=>10, :size=>10}}

query.fetch #=> Some lovely data
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/coryodaniel/munson.
