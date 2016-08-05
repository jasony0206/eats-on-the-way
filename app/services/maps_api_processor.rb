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
    [step['start_location'], step['end_location']]
  end
end
