ActionMailer::Base.default_options = {
  to: 'MyUSA <myusa@gsa.gov>',
  reply_to: 'myusa@gsa.gov',
  from: 'no-reply@' + ActionMailer::Base.default_url_options[:host]
}
