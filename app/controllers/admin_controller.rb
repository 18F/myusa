require 'csv'

class AdminController < ApplicationController
  layout 'dashboard'

  before_filter :require_admin!

  def index
    @applications = Doorkeeper::Application.
      includes(:authorizations).
      filter(params[:filter]).
      search(params[:search]).
      paginate(page: params[:page], per_page: 8)

    respond_to do |format|      
      format.html            
      
      format.json do
        @applications = Doorkeeper::Application.includes(:authorizations).all
        json_string = {applications: @applications}.as_json(methods: :number_of_authorizations)
        render(json: json_string, status: 200)
      end
      
      format.csv do
        @applications = Doorkeeper::Application.includes(:authorizations).all
        csv_string = CSV.generate do |csv|
          csv << Doorkeeper::Application.attribute_names
          @applications.each do |application|
            csv << application.attributes.values
          end
        end
        render(text: csv_string, status: 200)
      end
      
    end
  end

end
