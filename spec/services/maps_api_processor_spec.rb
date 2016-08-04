require 'rails_helper'

describe MapsApiProcessor do
  describe '.extract_coordinates' do
    context 'when API response has 3 steps' do
      let(:api_response) {
        IO.read(Rails.root.join("spec", "fixtures", "mock_directions_response"))
      }

      before do
        @extracted_coordinates = described_class.extract_coordinates(api_response)
      end

      it 'should return an array of coordinates' do
        expect(@extracted_coordinates).to be_an_instance_of(Array)
        expect(@extracted_coordinates).not_to be([])
        expect(@extracted_coordinates.first).to be_an_instance_of(Hash)
        expect(@extracted_coordinates.first.keys).to eq(['lat', 'lng'])
      end

      it 'should return 3 + 1 = 4 coordinates' do
        expect(@extracted_coordinates.count).to eq(4)
      end
    end
  end
end
