module YelpApiProcessor 
  def self.extract_businesses(yelp_api_response)
    begin
      businesses = yelp_api_response.businesses
    rescue
      # An error occurred, default to empty businesses
      businesses = []
    end

    # Only keep relevant information
    businesses.map! do |b|
      coordinate = b.location.coordinate
      { 
        'name' => b.name, 
        'rating' => b.rating, 
        'review_count' => b.review_count, 
        'location' =>
        {
          'latitude' => coordinate.latitude,
          'longitude' => coordinate.longitude
        }
      }
    end
  end
end
