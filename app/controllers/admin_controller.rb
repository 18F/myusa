class AdminController < ApplicationController
  layout 'dashboard'

  before_filter :require_admin!

  def index
    @applications = Doorkeeper::Application.
      filter(params[:filter]).
      search(params[:search]).
      paginate(page: params[:page], per_page: 8)
  end
end
