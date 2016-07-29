# Munson::Resource
class Artist < Munson::Resource
  self.type = :artists

  attribute :name, :string
  attribute :twitter, :string

  has_many :albums
  has_many :members
  has_one :record_label
end
