module MapsApiProcessor
  @@DISTANCE_THRESHOLD = 2000
  @@LOG_BASE = 10

  def self.extract_querypoints(directions_api_response)
    begin
      leg = directions_api_response['routes'].first['legs'].first
      steps = leg['steps']
      total_distance = leg['distance']['value']
    rescue
      # An error occurred, default to reasonable values
      steps = []
      total_distance = 0
    end

    querypoints = steps.map do |step|
      self.step_to_querypoints(step)
    end

    # Flatten into a 1D array of hashes
    querypoints.flatten!

    # Remove duplicate querypoints
    querypoints.uniq!

    # Too many querypoints leads to unreasonably long call back wait time
    # Only select a few querypoints
    num_to_extract = num_points_to_extract(total_distance)
    if querypoints.count > num_to_extract
      step_to_skip = querypoints.count / num_to_extract
      querypoints = (0...querypoints.count).step(step_to_skip).map do |index|
        querypoints[index]
      end
    end

    querypoints
  end

  def self.step_to_querypoints(step)
    start_coord = step['start_location']
    end_coord = step['end_location']
    lat_diff = end_coord['lat'] - start_coord['lat']
    lng_diff = end_coord['lng'] - start_coord['lng']

    num_intermediate_coords = step['distance']['value'] / @@DISTANCE_THRESHOLD
    lat_diff_step = lat_diff / (num_intermediate_coords + 1)
    lng_diff_step = lng_diff / (num_intermediate_coords + 1)

    coords = (1..num_intermediate_coords).map do |factor|
      {'lat' => start_coord['lat'] + (lat_diff_step * factor),
       'lng' => start_coord['lng'] + (lng_diff_step * factor)}
    end

    coords.unshift(start_coord)
    coords << end_coord
  end

  def self.num_points_to_extract(total_distance)
    log_result = Math.log(total_distance, @@LOG_BASE).floor
    if log_result >= 1
      log_result
    else
      1
    end
  end
end
