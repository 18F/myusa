require 'rails_helper'

describe ApplicationsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:app) { FactoryGirl.create(:application, owner_emails: user.email) }

  describe '#update' do
    subject { -> { put :update, id: app.id, application: application_params } }

    before :each do
      sign_in user
    end

    context 'when current user is removed from owner_emails' do
      let(:application_params) { { owner_emails: '' } }
      it 'does not update' do
        is_expected.to_not change { app.reload.owner_emails }
      end
    end
  end
end
