class HomeController < ApplicationController
  layout 'marketing', only: [:index, :legal, :developer]

  before_filter :clear_return_to, only: [:index]

  def contact_us
    send_contact_us_email

    respond_to do |format|
      format.json { render json: { success: true, message: 'Thank you. Your message has been sent.' } }
      format.html { redirect_to root_url, notice: 'Thank you. Your message has been sent.' }
    end
  end

  private

  def contact_params
    params.require(:contact_us).permit(:message, :from, :return_email)
  end

  def send_contact_us_email
    ContactMailer.contact_us(
      contact_params[:from],
      contact_params[:return_email],
      contact_params[:message]
    ).deliver
  end
end
