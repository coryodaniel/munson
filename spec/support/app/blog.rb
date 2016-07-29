class Article < Munson::Resource
  self.type = :articles
  munson.response_key_format = :dasherize

  has_one :author
  has_many :comments

  key_type :integer
  attribute :title, :string
end

class Person < Munson::Resource
  self.type = :people
  munson.response_key_format = :dasherize
  has_many :articles

  attribute :first_name, String
  attribute :last_name, :string
  attribute :twitter, :string
  attribute :created_at, :time, default: ->{ Time.now }, serialize: ->(val){ val.to_s }
  attribute :post_count, :integer
end

class Comment < Munson::Resource
  self.type = :comments
  munson.response_key_format = :dasherize
  has_one :author

  attribute :body, ->(val){ val.to_s }
  attribute :score, :float
  attribute :created_at, :time
  attribute :is_spam, :boolean
  attribute :mentions, :string, array: true
end
