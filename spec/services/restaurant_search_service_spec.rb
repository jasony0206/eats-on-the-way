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
end
