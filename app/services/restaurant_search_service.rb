module RestaurantSearchService
  def self.search(origin, destination)
    directions_api_response = GoogleMapsClient.find_directions(origin, destination)
    origin_coord = directions_api_response['routes'].first['legs'].first['start_location']
    destination_coord = directions_api_response['routes'].first['legs'].first['end_location']
    restaurants = find_restaurants(directions_api_response)
    top_25_restaurants = top_25(restaurants)
    total_info, o_to_r_info, r_to_d_info = find_travel_info([origin_coord], [destination_coord], top_25_restaurants)

    direct_travel = direct_travel_info(directions_api_response)
    # TODO: filter by cuisine
    final_restaurants = format_data(top_25_restaurants, total_info, o_to_r_info, r_to_d_info, direct_travel)
    final_results = {
      'start_location' => origin_coord,
      'end_location' => destination_coord,
      'direct_travel_info' => direct_travel,
      'restaurants' => final_restaurants
    }
  end

  def self.direct_travel_info(directions_api_response)
    begin
      leg = directions_api_response['routes'].first['legs'].first
      steps = leg['steps']
      distance = leg['distance']['value']
      duration = leg['duration']['value']
    rescue
      distance = 0
      duration = 0
    end

    {
      'distance' => distance,
      'duration' => duration
    }
  end

  def self.find_travel_info(origins, destinations, restaurants)
    coords = restaurants.map { |restaurant| restaurant['location'] }

    origin_to_restaurants_response = GoogleMapsClient.distance_matrix(origins, coords)
    restaurants_to_destination_response = GoogleMapsClient.distance_matrix(coords, destinations)

    origin_to_restaurants_array = MapsApiProcessor.one_to_many_distance_matrix(origin_to_restaurants_response)
    restaurants_to_destination_array = MapsApiProcessor.many_to_one_distance_matrix(restaurants_to_destination_response)
    total_travel_info_array = combine_results(origin_to_restaurants_array, restaurants_to_destination_array)

    [total_travel_info_array, origin_to_restaurants_array, restaurants_to_destination_array]
  end

  def self.find_restaurants(directions_api_response)
    # directions_api_response = GoogleMapsClient.find_directions(origin, destination)
    google_coordinates = MapsApiProcessor.extract_querypoints(directions_api_response)
    yelp_coordinates = convert_hash_keys(google_coordinates)

    restaurants = yelp_coordinates.map do |point|
      yelpApiResponse = YelpClient.search(point, { term: 'food' })
      YelpApiProcessor.extract_businesses(yelpApiResponse)
    end
    restaurants.flatten!

    # Remove duplicate restaurants
    restaurants.uniq
  end

  def self.format_data(restaurants, total_info, o_to_r_info, r_to_d_info, direct_travel)
    length = restaurants.count
    (0...length).map do |index|
      entry = {}
      entry.merge!(restaurants[index])
      entry['total_travel'] = total_info[index]
      entry['to_restaurant'] = o_to_r_info[index]
      entry['from_restaurant'] = r_to_d_info[index]

      added_distance_value = total_info[index]['distance']['value'] - direct_travel['distance']
      added_duration_value = total_info[index]['duration']['value'] - direct_travel['duration']

      added_distance_text = "#{meters_to_miles(added_distance_value)} mi"
      added_duration_text = secs_to_formatted_str(added_duration_value)

      entry['added_travel'] = {
        'distance' =>
          {
            'text' => added_distance_text,
            'value' => added_distance_value
          },
        'duration' =>
          {
            'text' => added_duration_text,
            'value' => added_duration_value
          }
      }

      entry
    end
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
      distance_text = "#{meters_to_miles(distance_value)} mi"

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

  def self.meters_to_miles(meters)
    (meters * 0.000621371).round(1)
  end
end
