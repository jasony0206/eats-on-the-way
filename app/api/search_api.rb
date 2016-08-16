module API
  class SearchAPI < Grape::API
    format :json
    
    get do
      {"message" => "hit search api endpoint!"}
    end
  end
end
