require 'rails_helper'

describe GoogleMapsClient do
  describe '.find_directions' do
    let(:origin) { 'Disneyland' }
    let(:destination) { 'Universal Studios Hollywood' }

    before do
      @response = described_class.find_directions(origin, destination)
    end

    it 'should receive a nonempty response' do
      expect(@response).not_to be_nil
    end

    it 'should return an OK status' do
      expect(@response['status']).to eq("OK")
    end
  end
end
