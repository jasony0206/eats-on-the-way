require 'rails_helper'

describe GoogleMapsClient do
  describe '.find_directions' do
    let(:origin) { 'Disneyland' }
    let(:destination) { 'Universal Studios Hollywood' }

    before do
      @result = described_class.find_directions(origin, destination)
    end

    it 'should receive a nonempty response' do
      expect(@result).not_to be_nil
    end

    it 'should return an OK status' do
      expect(@result['status']).to eq("OK")
    end
  end
end
