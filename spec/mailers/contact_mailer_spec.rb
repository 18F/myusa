require 'spec_helper'

describe SystemMailer do
  describe 'contact mailer' do
    let(:user) { FactoryGirl.create(:user) }
    let(:email) { user.email }
    let(:message) { 'we love the passwordless login flow!' }

    subject { SystemMailer.contact_email('User Name', email, message) }

    its(:subject) { should eql 'MyUSA question from User Name' }
    its(:reply_to) { should contain_exactly email }
    its('body.encoded') { should include message }
    its('body.encoded') { should include 'User Name'}
  end
end
