require 'rails_helper'

describe YelpClient do
  describe '.search_by_coordinates' do
    let(:coordinates) do
      { latitude: 37.7577, longitude: -122.4376 }
    end

    let(:params) do 
      { term: 'food' }
    end

    before do
      @response = described_class.search(coordinates, params)
    end

    it 'should retrun a nonempty response' do
      expect(@response).not_to be nil
    end

    it 'should contain an array of businesses' do
      expect(@response.businesses).not_to be nil
      expect(@response.businesses).to be_an_instance_of(Array)
    end
  end
end
