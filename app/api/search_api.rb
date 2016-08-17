module API
  class SearchAPI < Grape::API
    format :json
    
    params do
      requires :origin, type: String, desc: 'Start location of the travel'
      requires :destination, type: String, desc: 'End location of the travel'
    end
    get do
      RestaurantSearchService.search(params[:origin], params[:destination])
    end
  end
end
