ActionMailer::Base.default_options = {
  reply_to: 'myusa@gsa.gov',
  from: 'no-reply@' + ActionMailer::Base.default_url_options[:host]
}

ContactMailer.default to: 'myusa@gsa.gov'
