require 'yelp'

module YelpClient
  @@client = Yelp::Client.new({ consumer_key: ENV['YELP_CONSUMER_KEY'],
                                consumer_secret: ENV['YELP_CONSUMER_SECRET'],
                                token: ENV['YELP_TOKEN'],
                                token_secret: ENV['YELP_TOKEN_SECRET']
                              })

  def self.search(coordinates, params)
    @@client.search_by_coordinates(coordinates, params)
  end
end
