class ErrorsController < ApplicationController
  layout 'error'

  def not_found
    respond_to do |format|
      format.html { render status: 404 }
    end
  rescue ActionController::UnknownFormat
    render status: 404, text: "Page Not Found"
  end

  def unprocessable_entity
    respond_to do |format|
      format.html { render status: 422 }
    end
  rescue ActionController::UnknownFormat
    render status: 422, text: "Unprocessable Entity"
  end
end
