require 'feature_helper'

describe 'Two Factor Authentication', sms: true do
  let(:admin_page) { AdminPage.new }
  let(:sms_page) { TwoFactorAuthentication::SmsPage.new}

  let(:user) { FactoryGirl.create(:admin_user, :with_mobile_number) }
  let(:phone_number) { '800-555-3455' }

  def receive_code
    open_last_text_message_for(phone_number)
    expect(current_text_message.body).to match(/Your MyUSA verification code is \d{6}/)
    current_text_message.body.match /\d{6}/
  end


  before :each do
    login user
  end

  scenario 'visiting an admin-only page redirects to sms flow' do
    admin_page.load
    expect(sms_page).to be_displayed
  end

  scenario 'user can receive sms code' do
    sms_page.load
    expect(receive_code).to_not be_nil
  end

  context 'user submits code' do
    def code; receive_code; end

    before :each do
      admin_page.load
      sms_page.token.set code
      sms_page.submit.click
    end

    context 'code is bad' do
      def code; 'foobar'; end

      it 'shows error and displays sms form' do
      end
    end

    context 'code is correct' do
      it 'redirects back' do
        puts page.current_url
        expect(admin_page).to be_displayed
      end
    end
  end
end
