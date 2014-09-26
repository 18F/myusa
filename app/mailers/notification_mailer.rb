class NotificationMailer < ActionMailer::Base
  layout 'mailers/notification_template'
  def notification_email(notification)
    @notification = notification
    @app = @notification.app
    @user = User.find @notification.user_id
    attachments.inline['logo.png'] = File.read('app/assets/images/myusa-logo.png')
    mail(
      to: @user.email,
      from: @notification.email_from_address,
      reply_to: 'myusa@gsa.gov',
      subject: @notification.subject
    )
  end
end
