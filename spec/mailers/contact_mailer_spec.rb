require 'spec_helper'

describe ContactMailer do
  describe 'contact mailer' do
    let(:user) { FactoryGirl.create(:user) }
    let(:email) { user.email }
    let(:message) { 'we love the passwordless login flow!' }

    subject { ContactMailer.contact_us('User Name', email, message) }

    its(:subject) { should eql 'MyUSA question from User Name' }
    its(:reply_to) { should contain_exactly email }
    its('body.encoded') { should include message }
    its('body.encoded') { should include 'User Name'}
  end
end
