require 'spec_helper'

RSpec.describe Munson::Attribute do
  describe '#serialize' do
    context 'when a serialization proc is provided' do
      it "applies the proc to the value" do
        attribute = Munson::Attribute.new(:color, :string, serialize: ->(val){ val.to_s * 2 })
        value = attribute.serialize(:blue)
        expect(value).to eq "blueblue"
      end
    end

    context "when the serializer is a Symbol" do
      it "it calls the method on the value" do
        attribute = Munson::Attribute.new(:fav_number, :string, serialize: :to_i)
        value = attribute.serialize("2")
        expect(value).to eq 2
      end
    end

    context 'when the serializer is not set' do
      it "returns the value" do
        attribute = Munson::Attribute.new(:fav_number, :string)
        value = attribute.serialize(2)
        expect(value).to eq 2
      end
    end
  end
end
