require 'rails_helper'

describe SessionsController do
  let(:email) { 'testy@test.gov' }
  let(:date) { Date.new(1999, 12, 31) }

  before :each do
    Timecop.freeze(date)
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe '#new' do
    it 'should render a template' do
      get :new
      expect(response).to render_template(:new)
    end

    context 'email and token are present' do
      before :each do
        @user = User.create(email: email)
        @raw = @user.set_authentication_token
      end

      context 'and are valid' do
        it 'logs in and redirects the user' do
          get :new, :email => @user.email, :token => @raw

          expect(controller.current_user).to be
          expect(controller.current_user.email).to eq(@user.email)
          expect(response).to redirect_to(root_path)
        end
      end
      context 'token is bad' do
        it 'does not log user in' do
          get :new, :email => @user.email, :token => 'foobar'

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
