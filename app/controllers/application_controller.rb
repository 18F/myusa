class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  before_action :authenticate_user!, only: :secret
  
  def index
    render :text => 'Home page'
  end
  
  def secret
    render :text => 'You got me ' + current_user.email
  end
end
