class AdminController < ApplicationController
  layout 'dashboard'

  before_filter :require_admin!

  #TODO: maybe call this application(s)?
  def index
    @applications = filtered_applications.paginate(page: params[:page], per_page: 8)
  end

  private

  #TODO: maybe this belongs on the model? possibly a scope?
  def filtered_applications
    if params[:filter] && params[:filter] == 'pending-approval'
      Doorkeeper::Application.requested_public
    else
      Doorkeeper::Application
    end
  end

end
