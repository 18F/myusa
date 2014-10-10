class AdminController < ApplicationController
  layout 'dashboard'

  before_filter :require_admin!

  def index
    # render text: 'admins only!'
    @applications = Doorkeeper::Application.requested_public
  end

end
