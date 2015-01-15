class HomeController < ApplicationController
  layout 'marketing', only: [:index, :legal, :developer]

  before_filter :clear_return_to, only: [:index]

  def contact_us
    Feedback.create(
      user: current_user,
      from: contact_params[:from],
      email: contact_params[:return_email] || (user_signed_in? && current_user.email),
      message: contact_params[:message],
      remote_ip: request.remote_ip
    )

    #TODO: handle errors ... 
    respond_to do |format|
      format.json { render json: { success: true, message: 'Thank you. Your message has been sent.' } }
      format.html { redirect_to root_url, notice: 'Thank you. Your message has been sent.' }
    end
  end

  private

  def contact_params
    params.require(:contact_us).permit(:message, :from, :return_email)
  end

end
