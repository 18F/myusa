require 'rails_helper'

describe SessionsController do
  let(:email) { 'testy@test.gov' }
  let(:date) { Date.new(1999, 12, 31) }

  before :each do
    Timecop.freeze(date)
    request.env['devise.mapping'] = Devise.mappings[:user]
  end

  after :each do
    Timecop.return
  end

  describe '#new' do
    let(:user) { FactoryGirl.create(:user, :with_2fa, email: email) }

    context 'user is signed in' do
      before :each do
        sign_in user
      end

      it 'redirects' do
        get :new
        expect(response).to redirect_to(profile_path)
      end
    end

    context 'user is signed out' do
      it 'renders a template' do
        get :new
        expect(response).to render_template(:new)
      end

      context 'but user has a 2-factor scope signed in' do
        before :each do
          sign_in :two_factor, user.create_sms_code
        end

        it 'renders a template' do
          get :new
          expect(response).to render_template(:new)
        end
      end
    end

    context 'email and token are present' do
      let(:user) { FactoryGirl.create(:user, email: email) }

      context 'and are valid' do
        before :each do
          @token = AuthenticationToken.generate(
            user_id: user.id,
            remember_me: self.respond_to?(:remember_me) ? remember_me : nil,
            return_to: self.respond_to?(:return_to) ? return_to : nil
          )

          get :new,
            :email => user.email,
            :token => @token.raw
        end

        it 'logs in the user' do
          expect(controller.current_user).to be
          expect(controller.current_user.email).to eq(user.email)
        end

        it 'expires the token' do
          expect(AuthenticationToken.authenticate(controller.current_user, @token.raw)).to be_nil
        end

        context 'first time experience' do
          let(:user) { FactoryGirl.create(:user, :new_user, email: email) }
          it 'redirects to mobile recovery flow' do
            expect(response).to redirect_to(new_mobile_recovery_path)
          end
        end
        context 'return to path is not set' do
          it 'redirects to the profile path' do
            expect(response).to redirect_to(profile_path)
          end
        end
        context 'return to path is set' do
          let(:return_to) { profile_path }

          it 'redirects to the return path' do
            expect(response).to redirect_to(return_to)
          end
        end

        context 'remember_me is set' do
          let(:remember_me) { true }

          it 'sets the remember cookie' do
            expect(response.cookies).to have_key('remember_user_token')
          end
        end

        context 'remember_me is not set' do
          it 'does not set the remember cookie' do
            expect(response.cookies).to_not have_key('remember_user_token')
          end
        end

      end
    end
  end

  describe '#create' do
    subject { post :create, :user => { email: email } }

    context 'when user does not exist' do
      it 'creates a new user' do
        expect { subject }.to change { User.where(email: email).count }.by(1)
      end
      it 'creates a token' do
        expect { subject }.to change { AuthenticationToken.count }.by(1)
      end
    end

    context 'when user already exists' do
      let!(:user) { User.create!(email: email) }

      it 'does not create a new user' do
        expect { subject }.to_not change { User.where(email: email).count }
      end
      it 'creates a token for that user' do
        expect { subject }.to change { user.authentication_tokens.count }.by(1)
      end
    end
  end

  describe '#show' do
    before :each do
      allow(AuthenticationToken).to receive(:generate).and_call_original
    end

    let(:params) { { return_to: '/profile', remember_me: true } }

    subject { get :show, token_id: token_id }

    context 'with valid token id' do
      let(:token_id) { @token.id }

      it 'generates token with same parameters' do
        user = User.create(email: email)
        @token = user.set_authentication_token(params)

        expect { subject }.to change { user.authentication_tokens.count }.by(1)

        expect(AuthenticationToken).to have_received(:generate).twice.with(hash_including(params))
      end
    end
    context 'with invalid token id' do
      let(:token_id) { 'foobar' }

      it 'redirects to sign_in page' do
        is_expected.to redirect_to(new_user_session_path)
      end
    end
  end

  describe "#destroy" do
    let!(:user) { FactoryGirl.create(:user, :with_2fa, email: email) }
    let!(:application) { FactoryGirl.create(:application, owner: user, url: 'http://origin-staging.test.gov') }
    let!(:authorization) { FactoryGirl.create(:authorization, user: user, application: application) }
    let!(:access) { FactoryGirl.create(:access_token, resource_owner: user, application: application) }

    subject { get :destroy }

    context "user is signed in" do
      before :each do
        sign_in user
      end

      it "should clear the current user" do
        subject
        expect(controller.current_user).to_not be
      end

      it "should set the logged out user" do
        subject
        expect(controller.instance_variable_get('@logged_out_user')).to eq(user)
      end

      it "should redirect to the root" do
        is_expected.to redirect_to('http://test.host/')
      end
    end

    context "when passed a redirect" do
      before :each do
        sign_in user
        expect(Doorkeeper::Application.authorized_for(user).map(&:url)).to eq([application.url])
      end

      subject { get :destroy, continue: 'http://origin-staging.test.gov/user/sign_out' }

      it 'redirects to redirect argument' do
        is_expected.to redirect_to('http://origin-staging.test.gov/user/sign_out')
      end
    end

    context "user is not signed in" do
    end
  end
end
