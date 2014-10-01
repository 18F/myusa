require 'feature_helper'

describe 'Sign In' do
  let(:sign_in_page) { SignInPage.new }
  let(:target_page) { TargetPage.new }
  let(:sign_in_page) { SignInPage.new }
  let(:token_instructions_page) { TokenInstructionsPage.new }
  let(:profile_page) { ProfilePage.new }
  let(:home_page) { HomePage.new }
  let(:mobile_confirmation_page) { MobileConfirmationPage.new }

  let(:email_link_text) { 'Connect to MyUSA' }

  describe 'page' do
    before do
      sign_in_page.load
    end

    it 'has an app slogan' do
      expect(sign_in_page.slogan.text).to match('one account for government')
    end

    describe '"More Options" button,', js: true do
      describe 'at load time,' do
        specify { expect(sign_in_page).to have_more_options }
        specify { expect(sign_in_page).to_not have_less_options }
      end

      describe 'when clicked once,' do
        before do
          sign_in_page.more_options_link.click
          sign_in_page.wait_for_less_options
        end

        specify { expect(sign_in_page).to_not have_more_options }
        specify { expect(sign_in_page).to have_less_options }
      end
    end

    it 'signed-out user should be redirected to sign-in page' do
      target_page.load
      expect(sign_in_page).to be_displayed
    end
  end

  describe 'authentication', sms: true do
    let(:email) { 'testy@example.gov' }
    let(:instructions) { "CYM, #{email}" }
    let(:remember_me) { false  }
    let(:omniauth_provider) { :google_oauth2 }
    let(:omniauth_uid) { 12345 }

    let(:omniauth_hash) do
      OmniAuth::AuthHash.new(
        provider: omniauth_provider,
        uid: omniauth_uid,
        info: {
          email: email
        }
      )
    end

    before :each do
      clear_emails

      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[omniauth_provider] = omniauth_hash
    end

    before :each, create_user: true do
      FactoryGirl.create(:user, email: email)
    end

    shared_examples 'sign in' do
      before :each do
        perform_login!
      end

      it 'allows user to navigate directly to protected pages' do
        target_page.load
        expect(target_page).to be_displayed
      end

      it 'creates sign in audit record' do
        audit = UserAction.where(action: 'sign_in').last
        expect(audit.created_at).to be_within(5.seconds).of(Time.now)
      end
    end

    shared_examples 'sign in and redirect' do
      include_examples 'sign in'
      it 'allows user to authenticate and redirects' do
        expect(redirect_page).to be_displayed
      end
    end

    shared_examples 'sending token' do
      before :each do
        submit_form
      end

      it 'lets user know about the token email' do
        expect(token_instructions_page).to be_displayed
        expect(token_instructions_page.source).to match body
      end

      it 'sends the user an email with sign in link' do
        open_email(email)
        expect(current_email).to have_link(email_link_text)
      end

      describe 'resending token via email' do
        before :each do
          token_instructions_page.resend_link.click
          open_email(email)
        end

        it 'allows the user to resend token via email' do
          expect(token_instructions_page).to have_content(
            'A new access link has been sent to your email address.')
        end

        it 'sends the user an email' do
          expect(current_email).to have_link(email_link_text)
        end
      end
    end

    shared_examples 'remember me' do
      # CP: This is a crude hack. I couldn't find another way to ensure
      # the cookie was present. Ideally, Capybara would let me selectively
      # expire the session cookie to test that remember token authenticates
      # the new session automagically, but that didn't work at all. I did
      # not try to use Timecop to expire tokens because it has been shown
      # to break Capybara timeouts.
      def cookies
        Capybara.current_session.driver.request.cookies
      end

      before :each do
        perform_login!
      end

      context 'without remember me set' do
        it 'does not set remember cookie' do
          expect(cookies).to_not have_key('remember_user_token')
        end
      end

      context 'with remember me set' do
        let(:remember_me) { true }

        it 'sets remember cookie' do
          expect(cookies).to have_key('remember_user_token')
        end
      end
    end

    shared_examples 'mobile recovery' do
      before :each do
        perform_login!
      end

      let(:phone_number) { '415-555-3455' }

      it 'redirects user to mobile confirmation page' do
        expect(mobile_confirmation_page).to be_displayed
      end

      it 'sends an sms message with a verification code' do
        mobile_confirmation_page.mobile_number.set phone_number
        mobile_confirmation_page.submit.click

        open_last_text_message_for(phone_number)
        expect(current_text_message.body).to match(/Your MyUSA verification code is \d{6}/)
        raw_token = current_text_message.body.match /\d{6}/
      end

      it 'redirects to welcome page, which has redirect link' do
        mobile_confirmation_page.mobile_number.set phone_number
        mobile_confirmation_page.submit.click

        open_last_text_message_for(phone_number)
        expect(current_text_message.body).to match(/Your MyUSA verification code is \d{6}/)
        raw_token = current_text_message.body.match /\d{6}/

        mobile_confirmation_page.mobile_number_confirmation_token.set raw_token
        mobile_confirmation_page.submit.click

        expect(mobile_confirmation_page).to be_displayed
        expect(mobile_confirmation_page.heading).to have_content('Welcome to MyUSA')

        expect(mobile_confirmation_page).to have_redirect_link
        expect(mobile_confirmation_page).to have_meta_refresh

        mobile_confirmation_page.redirect_link.click
        expect(redirect_page).to be_displayed
      end
    end

    shared_context 'with email' do
      def perform_login!
        submit_form
        open_email(email)
        current_email.click_link(email_link_text)
      end

      def submit_form
        form.email.set email
        form.remember_me.set remember_me
        form.submit.click
      end
    end

    shared_context 'with google' do
      def perform_login!
        form.google_button.click
      end
    end

    shared_examples 'authentication flows' do
      context 'for the first time' do
        context 'with email' do
          include_context 'with email'
          it_behaves_like 'sign in and redirect'
          it_behaves_like 'sending token'
          it_behaves_like 'remember me'
        end

        context 'with google' do
          include_context 'with google'
          it_behaves_like 'sign in'
          it_behaves_like 'mobile recovery'
        end
      end

      context 'with existing user', create_user: true do
        context 'with email' do
          include_context 'with email'
          it_behaves_like 'sign in and redirect'
          it_behaves_like 'sending token'
          it_behaves_like 'remember me'
        end

        context 'with google' do
          include_context 'with google'
          it_behaves_like 'sign in and redirect'
        end
      end
    end

    context 'from sign in page' do
      let(:redirect_page) { profile_page }
      let(:form) { sign_in_page }

      before :each do
        sign_in_page.load
      end

      include_examples 'authentication flows'
    end

    context 'after redirect to sign in page' do
      let(:redirect_page) { target_page }
      let(:form) { sign_in_page }

      before :each do
        target_page.load
      end

      include_examples 'authentication flows'
    end

    context 'signing in from home page' do
      let(:redirect_page) { profile_page }
      let(:form) { home_page.login_form }

      before :each do
        home_page.load
      end

      include_examples 'authentication flows'
    end
  end
end
