class NotificationsController < ApplicationController

  def unsubscribe
    user = User.find_by_email(params[:email])
    raw_token = params[:token]
    if token = UnsubscribeToken.unsubscribe(user, raw_token)
      flash[:notice] = "You have been unsubscribed from #{token.notification.app.name}!"
    end

    redirect_to root_path
  end
end
