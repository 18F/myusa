class ContactMailer < ActionMailer::Base
  layout 'mailers/notification_template'
  def contact_us(from, return_email, message)
    @from = from
    @message = message
    @return_email = return_email
    attachments.inline['logo.png'] = File.read('app/assets/images/myusa-logo.png')
    mail(
      reply_to: @return_email,
      subject: I18n.t('email.contact_us.subject', from: @from)
    )
  end
end
