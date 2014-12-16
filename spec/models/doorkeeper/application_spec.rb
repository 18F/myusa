require 'rails_helper'

describe Doorkeeper::Application do
  it 'creation is audited' do
    app = FactoryGirl.build(:application)
    expect do
      app.save!
    end.to change { UserAction.where(record: app, action: 'create').count }.by(1)
  end

  it 'updates are audited' do
    app = FactoryGirl.create(:application)
    expect do
      app.update_attributes(name: 'My App', description: 'Is Awesome')
    end.to change { UserAction.where(record: app, action: 'update').count }.by(1)
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
