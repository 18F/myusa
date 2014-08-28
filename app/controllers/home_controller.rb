# HomeController
class HomeController < ApplicationController
  layout 'marketing', only: [:index]

  def contact_myusa
    User.send_email(contact_params)
    redirect_to root_url, notice: 'Thanks for contacting MyUSA.'
  end

  def contact_params
    params.permit(:message, :from, :return_field)
  end
end
