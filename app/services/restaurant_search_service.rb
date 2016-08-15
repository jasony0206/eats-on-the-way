module RestaurantSearchService
  def self.search(origin, destination)
    directionsApiResponse = GoogleMapsClient.find_directions(origin, destination)
    origin_coord = directionsApiResponse['routes'].first['legs'].first['start_location']
    destination_coord = directionsApiResponse['routes'].first['legs'].first['end_location']
    restaurants = find_restaurants(directionsApiResponse)
    total_info, o_to_r_info, r_to_d_info = find_travel_info([origin_coord], [destination_coord], restaurants)
    # TODO: map restaurant name to travel info, instead of matching by index
  end

  def self.find_travel_info(origins, destinations, restaurants)
    top_25 = top_25(restaurants)
    top_25_coords = top_25.map { |restaurant| restaurant['location'] }

    origin_to_restaurants_response = GoogleMapsClient.distance_matrix(origins, top_25_coords)
    restaurants_to_destination_response = GoogleMapsClient.distance_matrix(top_25_coords, destinations)

    origin_to_restaurants_array = MapsApiProcessor.one_to_many_distance_matrix(origin_to_restaurants_response)
    restaurants_to_destination_array = MapsApiProcessor.many_to_one_distance_matrix(restaurants_to_destination_response)
    total_travel_info_array = combine_results(origin_to_restaurants_array, restaurants_to_destination_array)

    [total_travel_info_array, origin_to_restaurants_array, restaurants_to_destination_array]
  end

  def self.find_restaurants(directionsApiResponse)
    # directionsApiResponse = GoogleMapsClient.find_directions(origin, destination)
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

  def self.combine_results(origin_to_restaurants_array, restaurants_to_destination_array)
    origin_to_restaurants_array.zip(restaurants_to_destination_array).map do |o_to_r, r_to_d|
      distance_value = o_to_r['distance']['value'] + r_to_d['distance']['value']
      distance_text = "#{(distance_value * 0.000621371).round(1)} mi"

      duration_value = o_to_r['duration']['value'] + r_to_d['duration']['value']
      duration_text = secs_to_formatted_str(duration_value)

      {
        'distance' =>
          {
            'text' => distance_text,
            'value' => distance_value
          },
        'duration' =>
          {
            'text' => duration_text,
            'value' => duration_value
          }
      }
    end
  end

  def self.secs_to_formatted_str(seconds)
    mm, ss = seconds.divmod(60)
    hh, mm = mm.divmod(60)
    if hh > 0
      "%s h %s min" % [hh, mm]
    else
      "%s min" % [mm]
    end
  end
end
