require 'rails_helper'

describe RestaurantSearchService do
  describe '.find_restaurants' do
    let(:directions_response) {
        json_response = IO.read(Rails.root.join("spec", "fixtures", "mock_directions_response"))
        JSON.parse(json_response)
      }

    before do
      @restaurants = described_class.find_restaurants(directions_response)
    end

    it 'should not return duplicate restaurants' do
      expect(@restaurants.count).to eq(@restaurants.uniq.count)
    end
  end

  describe '.search' do
    let(:mock_response) { IO.read(Rails.root.join("spec", "fixtures", "mock_search_api_response.json")) }

    it 'returned JSON response should be of valid schema' do
      json_schema_path = 'spec/fixtures/search_response_schema.json'
      is_valid = JSON::Validator.validate(json_schema_path, mock_response)
      expect(is_valid).to be true
    end
  end
end
