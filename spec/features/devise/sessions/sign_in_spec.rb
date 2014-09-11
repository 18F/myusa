require 'feature_helper'

describe 'Sign In' do
  describe 'page' do
    before do
      @page = SignInPage.new
      @page.load
    end

    it 'has an app slogan' do
      expect(@page.slogan.text).to match('one account for government')
    end

    describe '"More Options" button,', js: true do
      describe 'at load time,' do
        specify { expect(@page).to have_more_options }
        specify { expect(@page).to_not have_less_options }
      end

      describe 'when clicked once,' do
        before do
          @page.more_options_link.click
          @page.wait_for_less_options
        end

        specify { expect(@page).to_not have_more_options }
        specify { expect(@page).to have_less_options }
      end
    end
  end

  describe 'visiting the new session url' do
    let(:email) { 'testy@example.gov' }
    let(:user) { User.create!(email: email) }

    before :each do
      @target_page = TargetPage.new
      @sign_in_page = SignInPage.new
    end

    let(:token) { AuthenticationToken.generate(user_id: user.id) }

    context 'with an email address and valid token' do
      it 'logs them in' do
        visit new_user_session_path(email: user.email, token: token.raw)

        @target_page.load
        expect(@target_page).to be_displayed
      end
    end
    context 'with an email address and bad token' do
      it 'does not log them in' do
        visit new_user_session_path(email: user.email, token: 'foobar')

        @target_page.load
        expect(@sign_in_page).to be_displayed
      end
    end
  end

  describe 'with email' do
    before :each do
      @target_page = TargetPage.new
      @sign_in_page = SignInPage.new
    end

    it 'signed-out user should be redirected to sign-in page' do
      @target_page.load
      expect(@sign_in_page).to be_displayed
    end

    context 'Signing in for the first time' do
      describe 'with email address' do
        let(:email) { 'testy@example.gov' }
        let(:link_text) { 'Clicky' }
        let(:instructions) { "CYM, #{email}" }
        let(:remember_me) { false  }

        before :each do
          @token_instructions_page = TokenInstructionsPage.new
          clear_emails
          expect(User.find_by_email(email)).to be_nil

          @target_page.load
          @sign_in_page.email.set email
          @sign_in_page.remember_me.set remember_me
          @sign_in_page.submit.click
        end

        it 'creates a new user' do
          expect(User.find_by_email(email)).to be
        end

        it 'lets user know about the token email' do
          expect(@token_instructions_page).to be_displayed
          expect(@token_instructions_page.source).to match body
        end

        describe 'sends the user an email' do
          subject { open_email(email); current_email }
          it { should have_link(link_text) }
        end

        it 'allows user to authenticate with token' do
          open_email(email)
          current_email.click_link(link_text)

          expect(@target_page).to be_displayed
          expect(@target_page.source).to match body
        end

        describe 'remember me' do
          before :each do
            open_email(email)
            current_email.click_link(link_text)
            # CP: This is a crude hack. I couldn't find another way to ensure
            # the cookie was present. Ideally, Capybara would let me selectively
            # expire the session cookie to test that remember token authenticates
            # the new session automagically, but that didn't work at all. I did
            # not try to use Timecop to expire tokens because it has been shown
            # to break Capybara timeouts.
            @cookies = Capybara.current_session.driver.request.cookies
          end

          context 'without remember me set' do
            it 'does not set remember cookie' do
              expect(@cookies).to_not have_key('remember_user_token')
            end
          end

          context 'with remember me set' do
            let(:remember_me) { true }

            it 'sets remember cookie' do
              expect(@cookies).to have_key('remember_user_token')
            end
          end
        end
      end
    end
  end

  describe 'Authenticate with an external identity provider' do

    let(:email) { 'testo@example.com' }
    let(:uid) { '12345' }

    before :each do
      @target_page = TargetPage.new
      @sign_in_page = SignInPage.new
    end

    context 'with Google' do
      let(:provider) { :google_oauth2 }

      before :each do
        OmniAuth.config.test_mode = true
        OmniAuth.config.mock_auth[provider] = OmniAuth::AuthHash.new({
          provider: provider,
          uid: uid,
          info: {
            email: email
          }
        })
      end

      context 'user has already signed in with google' do
        before :each do
          User.create! do |user|
            user.email = email
            user.authentications.build(provider: provider, uid: uid)
          end

        end

        it 'redirects the user to the next point' do
          @target_page.load
          @sign_in_page.google_button.click
          expect(@target_page).to be_displayed
        end

        it 'allows user to navigate directly to protected pages' do
          @sign_in_page.load
          @sign_in_page.google_button.click
          @target_page.load
          expect(@target_page).to be_displayed
        end
      end

      context 'user has not signed in', sms: true do
        before :each do
          @mobile_confirmation_page = MobileConfirmationPage.new
        end

        let(:phone_number) { '415-555-3455' }

        it 'redirects user to mobile confirmation page' do
          @target_page.load
          @sign_in_page.google_button.click
          expect(@mobile_confirmation_page).to be_displayed
        end

        it 'welcome page has link to redirect back' do
          @target_page.load
          @sign_in_page.google_button.click

          @mobile_confirmation_page.mobile_number.set phone_number
          @mobile_confirmation_page.submit.click

          open_last_text_message_for(phone_number)
          expect(current_text_message.body).to match(/Your MyUSA verification code is \d{6}/)
          raw_token = current_text_message.body.match /\d{6}/

          @mobile_confirmation_page.mobile_number_confirmation_token.set raw_token
          @mobile_confirmation_page.submit.click

          expect(@mobile_confirmation_page).to be_displayed
          expect(@mobile_confirmation_page.heading).to have_content('Welcome to MyUSA')

          expect(@mobile_confirmation_page).to have_redirect_link
          expect(@mobile_confirmation_page).to have_meta_refresh

          @mobile_confirmation_page.redirect_link.click
          expect(@target_page).to be_displayed
        end
      end

    end
  end
end
