
require 'rails_helper'

# ProfilesController
describe ProfilesController, type: :controller do
  let(:email) { 'testy.mctesterson@example.com' }
  let(:user) { FactoryGirl.create(:user, email: email) }
  let(:profile) { FactoryGirl.create(:profile, user: user) }
  let(:private_app) do
    FactoryGirl.create(:application, name: 'Private', public: false, owner: user)
  end
  let(:public_app) do
    FactoryGirl.create(:application, name: 'Public', public: true, owner: user)
  end

  context 'user is signed in' do
    before do
      sign_in user
    end

    describe 'DELETE destroy' do
      before :each do
        @profile = profile
      end

      it 'destroys the user' do
        expect do
          delete :destroy, email: email
        end.to change(User, :count).by(-1)
      end

      it 'destroys the profile' do
        expect do
          delete :destroy, email: email
        end.to change(Profile, :count).by(-1)
      end

      context 'with an access token' do
        before do
          FactoryGirl.create(:access_token, resource_owner: user,
                                            application: public_app)
        end

        it 'destroys any access tokens' do
          expect do
            delete :destroy, email: email
          end.to change(Doorkeeper::AccessToken, :count).by(-1)
        end
      end

      context 'with an access grant' do
        before do
          FactoryGirl.create(:access_grant, resource_owner: user,
                                            application: public_app,
                                            redirect_uri: 'http://example.com')
        end

        it 'destroys any access grants' do
          expect do
            delete :destroy, email: email
          end.to change(Doorkeeper::AccessGrant, :count).by(-1)
        end
      end

      context 'with a public app' do
        before do
          @public_app = public_app
        end

        it 'does not destroy any owned public apps' do
          expect do
            delete :destroy, email: email
          end.to change(Doorkeeper::Application, :count).by(-1)
        end
      end

      context 'with a private app' do
        before do
          @private_app = private_app
        end

        it 'destroys any owned private apps' do
          expect do
            delete :destroy, email: email
          end.to change(Doorkeeper::Application, :count).by(-1)
        end
      end
    end
  end
end
