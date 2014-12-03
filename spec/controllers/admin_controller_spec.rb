require 'rails_helper'

describe AdminController do
  let(:user) { FactoryGirl.create(:admin_user) }

  describe '#index' do
    before :each do
      9.times { FactoryGirl.create(:application) }
      3.times { FactoryGirl.create(:application, :pending_approval) }
      sign_in :user, user
      sign_in :two_factor, user
    end

    context 'no params' do
      before :each do
        get :index
      end

      it 'gets 8 applications' do
        expect(assigns(:applications).length).to eq(8)
      end
    end

    context 'page 2' do
      before :each do
        get :index, page: 2
      end

      it 'gets the 2nd page' do
        first_page = Doorkeeper::Application.first(8)
        expect(assigns(:applications)).to_not include(*first_page)
      end
    end

    context 'filter by pending-approval' do
      before :each do
        get :index, filter: 'pending-approval'
      end

      it 'filters by applications pending approval' do
        expect(assigns(:applications)).to be_all(&:requested_public_at)
      end
    end
  end
end
