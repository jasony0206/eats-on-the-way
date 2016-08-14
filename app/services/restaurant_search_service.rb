module RestaurantSearchService
  def self.find_restaurants(origin, destination)
    directionsApiResponse = GoogleMapsClient.find_directions(origin, destination)
    google_coordinates = MapsApiProcessor.extract_querypoints(directionsApiResponse)
    yelp_coordinates = convert_hash_keys(google_coordinates)

    restaurants = yelp_coordinates.map do |point|
      yelpApiResponse = YelpClient.search(point, { term: 'food' })
      YelpApiProcessor.extract_businesses(yelpApiResponse)
    end
    restaurants.flatten!

    # Remove duplicate restaurants
    restaurants.uniq
  end

  def self.convert_hash_keys(google_coordinates)
    yelp_coordinates = google_coordinates.map do |google_point|
      yelp_point = {}
      yelp_point[:latitude] = google_point['lat']
      yelp_point[:longitude] = google_point['lng']
      yelp_point
    end
  end

  def self.top_25(restaurants)
    # Sort by rating & review_count in descending order
    restaurants.sort! { |a,b|
      [b['rating'], b['review_count']] <=> [a['rating'], a['review_count']]
    }

    # Distance Matrix API only allows 25 destinations per query
    restaurants[0..24]
  end
end
