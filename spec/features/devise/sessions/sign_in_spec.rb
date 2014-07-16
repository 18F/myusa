require 'feature_helper.rb'

describe "Sign In", js: true do

  describe "page" do
    before do
      @page = SignInPage.new
      @page.load
    end

    it "has an app slogan" do
      expect(@page.slogan.text).to match("Your one account for government.")
    end

    describe '"More Options" button,' do

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

  describe "Authenticate with an external identity provider" do
    def sign_in_to_target(target_page, sign_in_page)
      target_page.load
      sign_in_page.google_button.click
    end

    before :each do
      @target_page = TargetPage.new
      @sign_in_page = SignInPage.new
    end

    it "signed-out user should be redirected to sign-in page" do
      @target_page = TargetPage.new
      @target_page.load
      @sign_in_page = SignInPage.new
      expect(@sign_in_page).to be_displayed
    end

    context "Registering for the first time" do
      describe "using Google" do
        let(:email) { 'testo@example.com' }
        let(:body) { "You got me #{email}" }

        before do
          OmniAuth.config.test_mode = true
          OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
            provider: 'google_oauth2',
            uid: '12345',
            info: {
              email: email
            }
          })
        end

        it "should create a new user" do
          pending 'not creating a new user (for now)'
          expect(User.find_by_email(email)).to be_nil
          sign_in_to_target(@target_page, @sign_in_page)
          expect(User.find_by_email(email)).to exist
        end

        it "should redirect the user to the next point" do
          pending 'not creating a new user (for now)'
          sign_in_to_target(@target_page, @sign_in_page)
          expect(@target_page).to be_displayed
          expect(@target_page.source).to match body
        end

        context "when returning later in the session" do
          before do
            sign_in_to_target(@target_page, @sign_in_page)
            @target_page.load
          end

          it "should redirect the user straight to the next point" do
            pending 'not creating a new user (for now)'
            expect(@target_page).to be_displayed
            expect(@target_page.source).to match body
          end
        end
      end

      context "Signing in a registered user" do
        describe "using Google" do
          let(:email) { 'testo@example.com' }
          let(:body) { "You got me #{email}" }

          before do
            OmniAuth.config.test_mode = true
            OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
              provider: 'google_oauth2',
              uid: '12345',
              info: {
                email: email
              }
            })

            User.create!(email: email)
          end

          it "should redirect the user to the next point" do
            sign_in_to_target(@target_page, @sign_in_page)

            expect(@target_page).to be_displayed
            expect(@target_page.source).to match body
          end

        end
      end
    end
  end

end
