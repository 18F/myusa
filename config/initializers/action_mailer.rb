ActionMailer::Base.default_options = {
  to: Rails.configuration.myusa_sender_email,
  reply_to: Rails.configuration.myusa_sender_email,
  from: 'no-reply@' + ActionMailer::Base.default_url_options[:host]
}
