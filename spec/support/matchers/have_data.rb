RSpec::Matchers.define :have_data do |document_name|
  match do |response|
    data = JSON.parse File.read("spec/support/responses/#{document_name}.json"), symbolize_names: true
    expect(response.body).to match(data)
  end
end
