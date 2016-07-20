require 'spec_helper'

RSpec.describe Munson::KeyFormatter do
  let(:dashed_hash) do
    {
      :"top-level" => true,
      :"more" => {
        :"second-level" => true
      },
      :"etc" => [
        {
          :"in-an-array" => true
        }
      ]
    }
  end

  let(:camemlized_hash) do
    {
      topLevel: true,
      more: { secondLevel: true },
      etc: [{ inAnArray: true }]
    }
  end

  let(:underscored_hash) do
    {
      top_level: true,
      more: { second_level: true },
      etc: [{ in_an_array: true }]
    }
  end

  describe '.externalize' do
    it "dasherizes the keys" do
      formatter = Munson::KeyFormatter.new(:dasherize)
      hash = formatter.externalize(underscored_hash)
      expect(hash).to eq dashed_hash
    end

    it "camelizes the keys" do
      formatter = Munson::KeyFormatter.new(:camelize)
      hash = formatter.externalize(underscored_hash)
      expect(hash).to eq camemlized_hash
    end
  end

  describe '.internalize' do
    it "underscores dasherized keys" do
      formatter = Munson::KeyFormatter.new(:dasherize)
      hash = formatter.internalize(dashed_hash)
      expect(hash).to eq underscored_hash
    end

    it "underscores camelized keys" do
      formatter = Munson::KeyFormatter.new(:camelize)
      hash = formatter.internalize(camemlized_hash)
      expect(hash).to eq underscored_hash
    end
  end
end
