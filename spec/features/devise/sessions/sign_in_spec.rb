require 'feature_helper'

describe "Sign In" do

  describe "page" do
    before do
      @page = SignInPage.new
      @page.load
    end

    it "has an app slogan" do
      expect(@page.slogan.text).to match("Your one account for government.")
    end

    describe '"More Options" button,', js: true do

      describe 'at load time,' do
        specify { expect(@page).to have_more_options }
        specify { expect(@page).to_not have_less_options }
      end

      describe  'when clicked once,' do
        before do
          @page.more_options_link.click
          @page.wait_for_less_options
        end

        specify { expect(@page).to_not have_more_options }
        specify { expect(@page).to have_less_options }
      end
    end

  end

  describe "with email" do
    def sign_in_to_target(target_page, sign_in_page)
      target_page.load
      sign_in_page.google_button.click
    end

    before :each do
      @target_page = TargetPage.new
      @sign_in_page = SignInPage.new
    end

    it "signed-out user should be redirected to sign-in page" do
      @target_page.load
      expect(@sign_in_page).to be_displayed
    end

    context "Signing in for the first time" do
      describe "with email address" do
        let(:email) { 'testy@example.gov' }
        let(:link_text) { 'Clicky' }
        let(:instructions) { "CYM, #{email}" }

        before :each do
          @token_instructions_page = TokenInstructionsPage.new
          clear_emails
          expect(User.find_by_email(email)).to be_nil

          @target_page.load
          @sign_in_page.email.set email
          @sign_in_page.submit.click
        end

        it "should create a new user" do
          expect(User.find_by_email(email)).to be
        end

        it "should let user know about the token email" do
          expect(@token_instructions_page).to be_displayed
          expect(@token_instructions_page.source).to match body
        end

        it "should send the user an email with the token" do
          open_email(email)
          expect(current_email).to have_link(link_text)
        end

        it "should allow user to authenticate with token" do
          open_email(email)
          current_email.click_link(link_text)

          expect(@target_page).to be_displayed
          expect(@target_page.source).to match body
        end
      end
    end
  end

  describe "Authenticate with an external identity provider" do

    let(:email) { 'testo@example.com' }
    let(:uid) { '12345' }
    let(:secret) { "You got me #{email}" }

    before :each do
      @target_page = TargetPage.new
      @sign_in_page = SignInPage.new
    end

    context "with Google" do
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

      shared_examples "omniauth" do

        it "redirects the user to the next point" do
          expect(@target_page).to be_displayed
          expect(@target_page.source).to match secret
        end

        it "allows user to navigate directly to protected pages" do
          @target_page.load
          expect(@target_page).to be_displayed
          expect(@target_page.source).to match secret
        end

      end

      context "user has already signed in with google" do
        before :each do
          User.create! do |user|
            user.email = email
            user.authentications.build(provider: provider, uid: uid)
          end

          @target_page.load
          @sign_in_page.google_button.click
        end

        include_examples "omniauth"
      end

      context "user has signed in, but not with google" do
        before :each do
          User.create!(email: email)

          @target_page.load
          @sign_in_page.google_button.click
        end

        include_examples "omniauth"
      end

      context "user has not signed in" do
        before :each do
          @target_page.load
          @sign_in_page.google_button.click
        end

        include_examples "omniauth"
      end

    end
  end


end
