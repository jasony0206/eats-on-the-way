module YelpApiProcessor 
  def self.extract_businesses(yelp_api_response)
    begin
      businesses = yelp_api_response['businesses']
    rescue
      # An error occurred, default to empty businesses
      businesses = []
    end

    # Only keep relevant information
    businesses.map! do |business|
      business.slice('name', 'rating', 'review_count', 'location')
    end
  end
end
