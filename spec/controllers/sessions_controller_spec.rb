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
    it 'renders a template' do
      get :new
      expect(response).to render_template(:new)
    end

    context 'email and token are present' do
      let(:user) { User.create(email: email) }

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
end
