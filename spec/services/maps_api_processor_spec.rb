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

    context "When step's distance is more than 2000 meters" do
      let(:start_location) do
        JSON.parse({
          lat: 32.0,
          lng: 22.0
        }.to_json)
      end
      let(:end_location) do
        JSON.parse({
          lat: 30.0,
          lng: 24.0
        }.to_json)
      end

      let(:step_hash) do
        JSON.parse({
          distance: {
            value: 3000
          },
          end_location: end_location,
          start_location: start_location
        }.to_json)
      end

      before do
        @coordinates = described_class.step_to_coordinates(step_hash)
      end

      it 'should return floor(3000 / 2000) + 2 = 3 coordinates' do
        expect(@coordinates).to be_an_instance_of(Array)
        expect(@coordinates.count).to eq(3)
      end

      it 'should include start_location and end_location' do
        expect(@coordinates).to include(start_location)
        expect(@coordinates).to include(end_location)
      end

      it 'middle coords should lie between start & end locations' do
        middle_lat = @coordinates[1]['lat']
        middle_lng = @coordinates[1]['lng']
        lat_case1 = start_location['lat'] < middle_lat && middle_lat < end_location['lat']
        lat_case2 = end_location['lat'] < middle_lat && middle_lat < start_location['lat']
        lng_case1 = start_location['lng'] < middle_lng && middle_lng < end_location['lng']
        lng_case2 = end_location['lng'] < middle_lng && middle_lng < start_location['lng']
        expect(lat_case1 || lat_case2).to be true
        expect(lng_case1 || lng_case2).to be true
      end
    end
  end
end
