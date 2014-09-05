class ContactMailer < ActionMailer::Base
  def contact_us(from, return_email, message)
    @from = from
    @message = message
    mail(
      reply_to: return_email,
      subject: t('email.contact_us.subject')
    )
  end
end
