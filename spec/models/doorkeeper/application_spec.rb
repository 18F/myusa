require 'rails_helper'

describe Doorkeeper::Application do
  describe 'application scopes' do
    let(:application) { FactoryGirl.build(:application) }

    context 'with valid scopes' do
      it 'is valid' do
        expect(application).to be_valid
      end
    end

    context 'with invalid scopes' do
      it 'is not valid' do
        application.scopes = 'foo bar baz'
        expect(application).not_to be_valid
      end
    end
  end

  describe '#owner_emails=' do
    let(:owner) { FactoryGirl.create(:user) }
    let(:user) { FactoryGirl.create(:user) }
    let(:application) { FactoryGirl.create(:application, owner_emails: owner.email) }

    context 'when removing an email' do
      let(:application) { FactoryGirl.create(:application, owner_emails: "#{owner.email} #{user.email}") }
      subject { -> { application.owner_emails = owner.email } }

      it 'destroys the corresponding membership' do
        is_expected.to change { application.owners.include?(user) }.from(true).to(false)
      end
    end

    context 'when adding an email' do
      let(:email) { user.email }
      subject { -> { application.owner_emails = "#{owner.email} #{email}" } }

      context 'of a valid user (non-member)' do
        it 'creates a membership' do
          is_expected.to change { application.owners.include?(user) }.from(false).to(true)
        end
      end

      context 'that does not correspond to a user' do
        let(:email) { 'nobody@example.com' }
        it 'does not create a membership' do
          is_expected.to_not change { application.memberships }
        end
      end
    end
  end

  describe '#developer_emails=' do
    let(:owner) { FactoryGirl.create(:user) }
    let(:user) { FactoryGirl.create(:user) }
    let(:application) { FactoryGirl.create(:application, owner_emails: owner.email) }

    context 'when removing an email' do
      let(:application) { FactoryGirl.create(:application, owner_emails: owner.email,
                                                           developer_emails: user.email) }
      subject { -> { application.developer_emails = '' } }

      it 'destroys the corresponding membership' do
        is_expected.to change { application.developers.include?(user) }.from(true).to(false)
      end
    end

    context 'when adding an email' do
      let(:email) { user.email }
      subject { -> { application.developer_emails = email } }

      context 'of a valid user (non-member)' do
        it 'creates a membership' do
          is_expected.to change { application.developers.include?(user) }.from(false).to(true)
        end
      end

      context 'that does not correspond to a user' do
        let(:email) { 'nobody@example.com' }
        it 'does not create a membership' do
          is_expected.to_not change { application.memberships }
        end
      end
    end
  end

end
