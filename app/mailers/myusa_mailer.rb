class MyusaMailer < ActionMailer::Base

  before_action :add_logo

  def add_logo
    attachments.inline['logo.png'] = File.read('app/assets/images/myusa-logo.png')
  end

end
