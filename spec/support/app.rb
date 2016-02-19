# class User
#   include Munson::Resource
#   has_many :addresses
# end
#
# class Address
#   include Munson::Resource
#   belongs_to :user
# end

class Article
  def self.munson
    return @munson if @munson
    @munson = Munson::Agent.new
    @munson
  end

  munson.connection #=> Default Connection
  munson.path = 'articles'
end
