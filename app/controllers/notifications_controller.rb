class NotificationsController < ApplicationController

  before_filter :authenticate_user!, only: [:index]

  layout 'dashboard'

  def index
    @authorizations = current_user.oauth_tokens.select {|a| a.scopes.exists?('notifications')}
    @applications = @authorizations.map(&:application)
  end

  def subscribe
    delivery_method = params[:delivery_method]
    app_id = params[:app_id]

    enable_delivery_method(app_id, delivery_method)

    flash[:notice] = "You will no longer receive #{delivery_method} from #{app_name}"
    redirect_to notifications_path
  end

  def unsubscribe
    delivery_method = params[:delivery_method]
    app_id = params[:app_id]

    disable_delivery_method(app_id, delivery_method)

    flash[:notice] = "You will now receive #{delivery_method} from #{app_name}"
    redirect_to notifications_path
  end

  def unsubscribe_via_token
    delivery_method = params[:delivery_method]
    user = User.find_by_email(params[:email])
    raw_token = params[:token]

    if token = UnsubscribeToken.unsubscribe(user, raw_token, delivery_method)
      flash[:notice] = "You have been unsubscribed from #{token.notification.app.name}!"
    end
  end

  private

  def app_name
    if params[:app_id] == 'myusa'
      'MyUSA'
    else
      Doorkeeper::Application.find(params[:app_id]).name
    end
  end

  def enable_delivery_method(app_id, delivery_method)
    return if current_user.settings["notification_settings.app_#{app_id}.delivery_methods"].nil?
    return if current_user.settings["notification_settings.app_#{app_id}.delivery_methods"].include?(delivery_method)
    current_user.settings["notification_settings.app_#{app_id}.delivery_methods"].push(delivery_method)
    current_user.save!
  end

  def disable_delivery_method(app_id, delivery_method)
    current_user.settings["notification_settings.app_#{app_id}.delivery_methods"] ||=[]
    current_user.settings["notification_settings.app_#{app_id}.delivery_methods"].delete(delivery_method)
    current_user.save!
  end


end
