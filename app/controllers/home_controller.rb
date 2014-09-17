
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
            success: false, message: I18n.t('contact_form.failure')
          }
        end

        format.html do
          flash.now[:notice] = I18n.t('contact_form.failure')
          render 'application/index'
        end
      end
      return
    end

    send_contact_us_email

    respond_to do |format|
      format.json { render json: {:success => true, :message =>  I18n.t('contact_form.success') } }
      format.html { redirect_to root_url, notice: I18n.t('contact_form.success') }
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
