# Munson::Resource
class Member < Munson::Resource
  self.type = :members

  def name
    document[:name]
  end
end
