require 'rails_helper'

describe GoogleMapsClient do
  describe '.find_directions' do
    let(:origin) { 'Disneyland' }
    let(:destination) { 'Universal Studios Hollywood' }

    before do
      @response = described_class.find_directions(origin, destination)
    end

    it 'should receive a nonempty response' do
      expect(@response).not_to be nil
    end

    it 'should return an OK status' do
      expect(@response['status']).to eq("OK")
    end
  end

  describe '.distance_matrix' do
    let(:origins) do
      [
        { latitude: 40.6655101, longitude: -73.89188969999998 }
      ]
    end
    let(:destinations) do
      [
        { latitude: 40.6905615, longitude: -73.9976592},
        { latitude: 40.659569, longtidue: -73.933783},
        { latitude: 40.729029, longitude: -73.851524}
      ]
    end

    before do
      @response = described_class.distance_matrix(origins, destinations)
    end

    it 'should receive a nonempty response' do
      expect(@response).not_to be nil
    end

    it 'should return an OK status' do
      expect(@response['status']).to eq("OK")
    end
  end
end
