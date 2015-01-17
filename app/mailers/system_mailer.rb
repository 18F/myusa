class SystemMailer < MyusaMailer
  layout 'mailers/notification_template'

  def contact_email(from, return_email, message)
    @from = from
    @message = message
    @return_email = return_email
    @metadata = {
      title: t('email.contact_us.subject', from: @from)
    }
    @metadata[:subject] = @metadata[:title]
    mail(
      reply_to: @return_email,
      subject: @metadata[:subject]
    )
  end

  def app_public_email(application, user)
    @app = application
    @user = user
    @metadata = {
      title: t('email.app_public.subject', name: @app.name)
    }
    @metadata[:subject] = @metadata[:title]

    attachments.inline['logo.png'] = File.read('app/assets/images/myusa-logo.png')
    mail(
      subject: @metadata[:subject]
    )
  end

end
