# Unregisterd, no initializer, mapper will return documents
class Venue
  def self.munson
    return @munson if @munson
    @munson = Munson::Client.new.configure do |c|
      c.type = :venues
    end
  end
end
