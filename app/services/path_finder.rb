require 'open-uri'

module PathFinder
  @@GOOGLE_API_KEY = ENV['GOOGLE_API_KEY']
  @@MAPS_URL_TEMPLATE = 'https://maps.googleapis.com/maps/api/directions/json?origin=%s&destination=%s&key=%s'

  def self.find_path(origin, destination)
    encoded_origin = CGI::escape(origin)
    encoded_destination = CGI::escape(destination)
    maps_url = @@MAPS_URL_TEMPLATE % [encoded_origin, encoded_destination, @@GOOGLE_API_KEY]

    result = JSON.parse(open(maps_url).read)
    steps = result['routes'].first['legs'].first['steps']
  end
end
