ActionMailer::Base.default_options = {
  to: ENV['sender_email'],
  reply_to: ENV['sender_email'],
  from: 'no-reply@' + ActionMailer::Base.default_url_options[:host]
}
