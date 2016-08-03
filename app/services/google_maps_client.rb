require 'open-uri'

module GoogleMapsClient
  @@GOOGLE_API_KEY = ENV['GOOGLE_API_KEY']
  @@MAPS_URL_TEMPLATE = 'https://maps.googleapis.com/maps/api/directions/json?origin=%s&destination=%s&key=%s'

  def self.find_directions(origin, destination)
    encoded_origin = CGI::escape(origin)
    encoded_destination = CGI::escape(destination)
    maps_url = @@MAPS_URL_TEMPLATE % [encoded_origin, encoded_destination, @@GOOGLE_API_KEY]

    result = JSON.parse(open(maps_url).read)
  end
end
