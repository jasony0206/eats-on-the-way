require 'rails_helper'

describe MapsApiProcessor do
  describe '.extract_querypoints' do
    context 'when API returns mock_directions_response' do
      let(:api_response) {
        json_response = IO.read(Rails.root.join("spec", "fixtures", "mock_directions_response"))
        JSON.parse(json_response)
      }

      before do
        @extracted_querypoints = described_class.extract_querypoints(api_response)
      end

      it 'should return an array of querypoints' do
        expect(@extracted_querypoints).to be_an_instance_of(Array)
        expect(@extracted_querypoints).not_to be([])
        expect(@extracted_querypoints.first).to be_an_instance_of(Hash)
        expect(@extracted_querypoints.first.keys).to eq(['lat', 'lng'])
      end
    end
  end

  describe '.step_to_querypoints' do
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
        @querypoints = described_class.step_to_querypoints(step)
      end

      it 'should return maximum 2 querypoints' do
        expect(@querypoints).to be_an_instance_of(Array)
        expect(@querypoints.count).to be <= 2
      end

      it 'should include start_location' do
        expect(@querypoints).to include({'lat' => 31.0, 'lng' => 21.0})
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
        @querypoints = described_class.step_to_querypoints(step_hash)
      end

      it 'should return floor(3000 / 2000) + 2 = 3 querypoints' do
        expect(@querypoints).to be_an_instance_of(Array)
        expect(@querypoints.count).to eq(3)
      end

      it 'should include start_location and end_location' do
        expect(@querypoints).to include(start_location)
        expect(@querypoints).to include(end_location)
      end

      it 'middle coords should lie between start & end locations' do
        middle_lat = @querypoints[1]['lat']
        middle_lng = @querypoints[1]['lng']
        lat_case1 = start_location['lat'] < middle_lat && middle_lat < end_location['lat']
        lat_case2 = end_location['lat'] < middle_lat && middle_lat < start_location['lat']
        lng_case1 = start_location['lng'] < middle_lng && middle_lng < end_location['lng']
        lng_case2 = end_location['lng'] < middle_lng && middle_lng < start_location['lng']
        expect(lat_case1 || lat_case2).to be true
        expect(lng_case1 || lng_case2).to be true
      end
    end
  end

  describe '.num_points_to_extract' do
    context 'when total distance is very short' do
      let(:total_distance) { 5 }

      before do
        @num_points = described_class.num_points_to_extract(total_distance)
      end

      it 'should return at least 1' do
        expect(@num_points).to be >= 1
      end
    end

    context 'when total distance is reasonable' do
      let(:total_distance) { 30000 }

      before do
        @num_points = described_class.num_points_to_extract(total_distance)
      end

      it 'should not exceed 5 requests' do
        expect(@num_points).to be <= 5
      end
    end

    context 'when total distance is very long' do
      let(:total_distance) { 500000 }

      before do
        @num_points = described_class.num_points_to_extract(total_distance)
      end

      it 'should not exceed 8 requests' do
        expect(@num_points).to be <= 8
      end
    end
  end
end
