# HomeController
class HomeController < ApplicationController
  layout 'marketing', only: [:index]

  def contact_myusa
    User.send_email(contact_params)
    respond_to do |format|
      format.json { render json: {:success => true, :message => 'Thank you. Your message has been sent.' } }
      format.html { redirect_to root_url, notice: 'Thank you. Your message has been sent.' }
    end
  end

  def contact_params
    params.permit(:message, :from, :return_field)
  end
end
