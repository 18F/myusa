class HomeController < ApplicationController
  layout 'marketing', only: [:index, :legal, :developer]

  def index
    render 'application/index'
  end

  def contact_us
    if params[:contact_us].blank? || params[:contact_us][:message].blank?
      respond_to do |format|
        format.json do
          render json: {
            success: false, message: 'Could not send empty message.'
          }
        end

        format.html do
          flash.now[:notice] = 'Could not send empty message.'
          render 'application/index'
        end
      end
      return
    end

    send_contact_us_email

    respond_to do |format|
      format.json { render json: {:success => true, :message => 'Thank you. Your message has been sent.' } }
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
