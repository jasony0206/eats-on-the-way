require 'open-uri'

module GoogleMapsClient
  @@GOOGLE_API_KEY = ENV['GOOGLE_API_KEY']
  @@DIRECTIONS_URL_TEMPLATE = 'https://maps.googleapis.com/maps/api/directions/json?origin=%s&destination=%s&key=%s'
  @@DISTANCE_MATRIX_URL_TEMPLATE = 'https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=%s&destinations=%s&key=%s'

  def self.find_directions(origin, destination)
    encoded_origin = CGI::escape(origin)
    encoded_destination = CGI::escape(destination)
    maps_url = @@DIRECTIONS_URL_TEMPLATE % [encoded_origin, encoded_destination, @@GOOGLE_API_KEY]

    result = JSON.parse(open(maps_url).read)
  end

  def self.distance_matrix(origins, destinations)
    formatted_origins = origins.map do |coord|
      coord.values.join(",")
    end
    origins_string = formatted_origins.join("|")

    formatted_destinations = destinations.map do |coord|
      coord.values.join(",")
    end
    destinations_string = formatted_destinations.join("|")

    distance_matrix_url = @@DISTANCE_MATRIX_URL_TEMPLATE % [origins_string, destinations_string, @@GOOGLE_API_KEY]
    result = JSON.parse(open(distance_matrix_url).read)
  end
end
