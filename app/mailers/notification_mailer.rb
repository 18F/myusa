class NotificationMailer < MyusaMailer
  layout 'mailers/notification_template'
  def notification_email(notification, unsubscribe_token)
    @notification = notification
    @app = @notification.app
    @user = @notification.user
    @unsubscribe_token = unsubscribe_token
    @metadata = {
      title: t('email.notification.subject', name: @app.name, subject: @notification.subject),
      subject: @notification.subject,
      footer: true
    }

    mail(
      to: @user.email,
      subject: @metadata[:subject]
    )
  end
end
