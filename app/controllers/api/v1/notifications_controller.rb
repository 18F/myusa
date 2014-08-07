class Api::V1::NotificationsController < Api::ApiController
  doorkeeper_for :create, scopes: ['notifications']

  def create
    notification = current_resource_owner.notifications.build(notification_params)
    notification.received_at = Time.now
    notification.user_id = current_resource_owner.id
    notification.app_id = doorkeeper_token.application.id
    if notification.save
      render :json => notification, :status => 200
    else
      render :json => {:message => notification.errors}, :status => 400
    end
  end

  protected

  def notification_params
    params.require(:notification).permit(:body, :subject)
  end

  # def no_scope_message
  #   "You do not have permission to send notifications to that user."
  # end

  # def oauthorize_scope
  #   validate_oauth(OauthScope.where(scope_name: 'notifications'))
  # end

end
