require 'rails_helper'

describe API::SearchAPI do
  describe 'GET' do
    before do
      get '/'
    end

    it 'should return a 200' do
      expect(response.status).to eq(200)
    end

    it 'should return a nonempty response' do
      expect(response.body).not_to be nil
    end
  end
end
