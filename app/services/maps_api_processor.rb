module MapsApiProcessor
  @@DISTANCE_THRESHOLD = 2000

  def self.extract_coordinates(directions_api_response)
    begin
      steps = directions_api_response['routes'].first['legs'].first['steps']
    rescue
      # An error occurred, default to empty steps
      steps = []
    end

    # A step's end_location is the same as next step's start_location
    # So ignore end_location, except for the very last step
    coordinates = steps.map { |step| step['start_location'] }
    coordinates << steps.last['end_location']
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
end
