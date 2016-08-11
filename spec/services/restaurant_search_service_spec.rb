require 'rails_helper'

describe RestaurantSearchService do
  describe '.find_restaurants' do
    let(:origin) { 'Origin City'}
    let(:destination) { 'destination' }

    before do
      @restaurants = described_class.find_restaurants(origin, destination)
    end

    it 'should not return duplicate restaurants' do
      expect(@restaurants.count).to eq(@restaurants.uniq.count)
    end
  end
end
