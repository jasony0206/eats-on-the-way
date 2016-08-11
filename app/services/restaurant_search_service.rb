module RestaurantSearchService
  def self.find_restaurants(origin, destination)
    directionsApiResponse = GoogleMapsClient.find_directions(origin, destination)
    google_coordinates = MapsApiProcessor.extract_coordinates(directionsApiResponse)
    yelp_coordinates = convert_hash_keys(google_coordinates)

    restaurants = yelp_coordinates.map do |point|
      yelpApiResponse = YelpClient.search(point, { term: 'food' })
      YelpApiProcessor.extract_businesses(yelpApiResponse)
    end
    restaurants.flatten!

    # Remove duplicate restaurants
    restaurants.uniq!
  end

  def self.convert_hash_keys(google_coordinates)
    yelp_coordinates = google_coordinates.map do |google_point|
      yelp_point = {}
      yelp_point[:latitude] = google_point['lat']
      yelp_point[:longitude] = google_point['lng']
      yelp_point
    end
  end
end
