require 'rails_helper'

describe Doorkeeper::Application do
  let(:application) { FactoryGirl.create(:application) }

  describe 'auditing' do
    context 'creation' do
      it 'is audited' do
        expect do
          FactoryGirl.create(:application)
        end.to change { UserAction.where(record_type: 'Doorkeeper::Application', action: 'create').count }.by(1)
      end
    end

    context 'updates' do
      it 'is audited' do
        expect do
          application.update_attributes(name: 'My App', description: 'Is Awesome')
        end.to change { UserAction.where(record: application, action: 'update').count }.by(1)
      end
    end
  end

  describe 'destroy' do
    before :each do
      FactoryGirl.create(:authorization, application: application)
    end

    it 'deletes authorization objects' do
      expect do
        application.destroy
      end.to change { Authorization.count }.by(-1)
    end
  end

  describe 'validations' do
    context 'application is not owned by a federal agency and does not have TOS accepted' do
      let(:application) { FactoryGirl.build(:application, federal_agency: false, terms_of_service_accepted: false) }
      it 'does not fail validation' do
        expect(application.save).to be_truthy
      end
    end

    context 'application is owned by a federal agency' do
      context 'TOS is not accepted' do
        let(:application) { FactoryGirl.build(:application, :federal_agency, terms_of_service_accepted: false) }
        it 'fails validation' do
          expect(application.save).to be_falsy
        end
      end

      context 'organzation is blank' do
        let(:application) { FactoryGirl.build(:application, :federal_agency, organization: '') }
        it 'fails validation' do
          expect(application.save).to be_falsy
        end
      end

      context 'TOS is accepted' do
        let(:application) { FactoryGirl.build(:application, :federal_agency, terms_of_service_accepted: true) }
        it 'does not fail validation' do
          expect(application.save).to be_truthy
        end
      end
    end
  end

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

    context 'with no scopes' do
      it 'is valid' do
        application.scopes = nil
        expect(application).to be_valid
      end
    end
  end

  describe '#logo_url' do
    let(:application) { FactoryGirl.build(:application) }

    context 'with valid logo_url' do
      it 'is valid' do
        application.logo_url = 'https://www.example.com'
        expect(application).to be_valid
      end
    end

    context 'with invalid logo_url' do
      it 'is valid' do
        application.logo_url = 'http://www.example.com'
        expect(application).not_to be_valid
      end
    end
  end

end
