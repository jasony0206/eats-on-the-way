require 'rails_helper'

describe YelpApiProcessor do
  describe '.extract_businesses' do
    context 'when API response has 3 businesses' do
      let(:api_response) {
        yelp_response = IO.read(Rails.root.join("spec", "fixtures", "mock_yelp_response"))
        json = JSON.parse(yelp_response)
        Yelp::Response::Search.new(json)
      }

      before do
        @extracted_businesses = described_class.extract_businesses(api_response)
      end

      it 'should return an array of 3 businesses' do
        expect(@extracted_businesses).not_to be nil
        expect(@extracted_businesses).to be_an_instance_of(Array)
        expect(@extracted_businesses.count).to eq(3)
      end

      it 'a business should have desired keys, and only those keys' do
        business_keys = @extracted_businesses.first.keys
        expect(business_keys).to include('name')
        expect(business_keys).to include('rating')
        expect(business_keys).to include('review_count')
        expect(business_keys).to include('location')
        expect(business_keys.count).to eq(4)
      end
    end
  end
end
