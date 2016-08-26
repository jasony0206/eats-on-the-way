class HomeController < ApplicationController

  def index
    render :text => "<h3>This is home controller!</h3>".html_safe
  end
end
