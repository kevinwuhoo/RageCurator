class ApplicationController < ActionController::Base
  protect_from_forgery
 
  private
 
  def authenticate
    authenticate_or_request_with_http_basic do |user_name, password|
      user_name == ENV['rage_curator_user'] && password == ENV['rage_curator_pass']
    end
  end
  
end
