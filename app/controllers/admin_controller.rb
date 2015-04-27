require 'csv'

class AdminController < ApplicationController
  layout 'dashboard'

  before_filter :require_admin!

  def index
    @applications = Doorkeeper::Application.includes(:authorizations)

    respond_to do |format|
      format.html do
        @applications = @applications.
              filter(params[:filter]).
              search(params[:search]).
              paginate(page: params[:page], per_page: 8)
      end

      format.json do
        json_string = {applications: @applications.all}.as_json(methods: :number_of_authorizations)
        render(json: json_string, status: 200)
      end

      format.csv do
        render(text: generate_csv(@applications), status: 200)
      end

    end
  end

  private

  def generate_csv(applications)
    CSV.generate do |csv|
      csv << Doorkeeper::Application.attribute_names
      applications.all.each do |application|
        csv << application.attributes.values
      end
    end
  end

end
