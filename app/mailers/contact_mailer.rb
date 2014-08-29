# contact us mailer
class ContactMailer < ActionMailer::Base
  default from: "no-reply@#{Rails.env}.my.usa.gov."

  def contact_email(message)
    @message = message
    mail(to: 'myusa@gsa.gov', subject: 'Contact - MyUSA marketing page')
  end
end
