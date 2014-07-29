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
      let(:remember_me) { nil }

      context 'and are valid' do
        before :each do
          raw = user.set_authentication_token
          get :new,
            :email => user.email,
            :token => raw,
            :remember_me => remember_me
        end

        it 'logs in and redirects the user' do
          expect(controller.current_user).to be
          expect(controller.current_user.email).to eq(user.email)
          expect(response).to redirect_to(root_path)
        end

        it 'expires the token' do
          expect(controller.current_user.authentication_token).to be_nil
        end

        context 'remember_me is set' do
          let(:remember_me) { true }

          it 'sets the remember cookie' do
            expect(@response.cookies).to have_key('remember_user_token')
          end
        end

        context 'remember_me is not set' do
          it 'does not set the remember cookie' do
            expect(@response.cookies).to_not have_key('remember_user_token')
          end
        end

      end

      context 'token is bad' do
        it 'does not log user in' do
          get :new, :email => user.email, :token => 'foobar'

          expect(controller.current_user).to be_nil
        end
      end

      context 'token is old' do
        before :each do
          Timecop.travel(date - 1.day)
          raw = user.set_authentication_token
          Timecop.travel(date)
          get :new, :email => user.email, :token => raw
        end

        it 'displays a flash alert' do
          expect(flash[:alert]).to eq('token expired')
        end

        it 'does not log user in' do
          expect(controller.current_user).to be_nil
        end
      end
    end
  end

  describe '#create' do
    shared_examples "token creation" do

      it 'sets a token on the user' do
        expect(@user.authentication_token).to be
      end

      it 'records the time when the token was created' do
        expect(@user.authentication_sent_at).to eq(date)
      end

    end

    context 'when user does not exist' do
      before :each do
        expect(User.find_by_email(email)).to be_nil

        post :create, :user => {
          email: email
        }

        @user = User.find_by_email(email)
      end

      it 'creates a new user' do
        expect(@user).to be
      end

      include_examples "token creation"

    end

    context 'when user already exists' do
      before :each do
        @user = User.create(email: email)

        post :create, :user => {
          email: email
        }

        @user.reload
      end

      include_examples "token creation"
    end
  end

end
