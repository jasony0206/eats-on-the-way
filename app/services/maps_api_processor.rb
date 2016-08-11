module MapsApiProcessor
  @@DISTANCE_THRESHOLD = 2000
  @@LOG_BASE = 10

  def self.extract_coordinates(directions_api_response)
    begin
      steps = directions_api_response['routes'].first['legs'].first['steps']
    rescue
      # An error occurred, default to empty steps
      steps = []
    end

    coordinates = steps.map do |step|
      self.step_to_coordinates(step)
    end

    # Flatten into a 1D array of hashes
    coordinates.flatten!

    # Remove duplicate coordinates
    coordinates.uniq!
  end

  def self.step_to_coordinates(step)
    start_coords = step['start_location']
    end_coords = step['end_location']
    lat_diff = end_coords['lat'] - start_coords['lat']
    lng_diff = end_coords['lng'] - start_coords['lng']

    num_intermediate_coords = step['distance']['value'] / @@DISTANCE_THRESHOLD
    lat_diff_step = lat_diff / (num_intermediate_coords + 1)
    lng_diff_step = lng_diff / (num_intermediate_coords + 1)

    coords = (1..num_intermediate_coords).map do |factor|
      {'lat' => start_coords['lat'] + (lat_diff_step * factor),
       'lng' => start_coords['lng'] + (lng_diff_step * factor)}
    end

    coords.unshift(start_coords)
    coords << end_coords
  end

  def self.num_coords_to_extract(total_distance)
    log_result = Math.log(total_distance, @@LOG_BASE).floor
    if log_result >= 1
      log_result
    else
      1
    end
  end
end
