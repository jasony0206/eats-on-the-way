require 'rails_helper'

describe MapsApiProcessor do
  describe '.extract_coordinates' do
    context 'when API response has 3 steps' do
      let(:api_response) {
        json_response = IO.read(Rails.root.join("spec", "fixtures", "mock_directions_response"))
        JSON.parse(json_response)
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

  describe '.step_to_coordinates' do
    context "when step's distance is less than 2000 meters" do
      let(:step) do
        step_json = {
          distance: {
            value: 500
          },
          end_location: {
            lat: 30.0,
            lng: 20.0
          },
          start_location: {
            lat: 31.0,
            lng: 21.0
          }
        }.to_json
        JSON.parse(step_json)
      end

      before do
        @coordinates = described_class.step_to_coordinates(step)
      end

      it 'should return 2 coordinates' do
        expect(@coordinates).to be_an_instance_of(Array)
        expect(@coordinates.count).to eq(2)
      end

      it 'should return start_location and end_location' do
        expect(@coordinates).to eq([{'lat' => 31.0, 'lng' => 21.0},
                                    {'lat' => 30.0, 'lng' => 20.0}])
      end
    end
  end
end
