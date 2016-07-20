# Registered type, non-Munson::Resource w/ initialize
class Album
  attr_accessor :id
  attr_accessor :title

  def self.munson
    return @munson if @munson
    @munson = Munson::Client.new
  end

  munson.type = :albums
  Munson.register_type(munson.type, self)

  def self.munson_initializer(document)
    new(document)
  end

  def initialize(document)
    @id    = document.id
    @title = document.attributes[:title]
  end
end
