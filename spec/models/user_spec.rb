require 'rails_helper'

describe User, type: :model do

  it { should have_one :profile }
  it { should validate_uniqueness_of :uid }

  # This fails due to the implementation of shoulda-matchers.
  # But: does this show up a problem in how we're generating UIDs? -- Yoz
  # it { should validate_presence_of :uid }


  describe "#create" do
    let(:valid_attributes) { { email: 'joe@citizen.org' } }


    context "created with valid attributes" do
      subject      { described_class.create!(valid_attributes) }
      it           { should be_instance_of described_class }
      it           { should be_valid }
      its(:errors) { should be_empty }
      its(:uid)    { should match /[0-9a-f\-]{36}/ }
    end

    context "created without an email address" do
      subject      { described_class.create(valid_attributes.reject { |k, _| k == :email }) }
      it           { should_not be_valid }
      its(:errors) { should_not include("I'm sorry, your account hasn't been approved yet.") }
      its(:errors) { should_not be_empty }
    end

    context "created with an invalid email address" do
      subject      { described_class.create(valid_attributes.merge(email: 'not_valid')) }
      it           { should_not be_valid }
      its(:errors) { should_not include("I'm sorry, your account hasn't been approved yet.") }
      its(:errors) { should_not be_empty }
    end
  end

  describe "#find_from_omniauth" do
    let(:email) { 'testy@example.gov' }
    let(:first_name) { 'testy' }
    let(:last_name) { 'tester' }
    let(:gender) { 'female' }
    let(:phone) { '987-654-3210' }
    let(:uid) { '12345' }

    let(:provider) { 'google_oauth2' }
    let(:auth_hash) do
      OmniAuth.config.mock_auth[provider] = OmniAuth::AuthHash.new(
        provider: provider,
        uid: uid,
        info: OmniAuth::AuthHash.new(
          email: email,
          first_name: first_name,
          last_name: last_name,
          phone: phone
        ),
        extra: OmniAuth::AuthHash.new(
          raw_info: OmniAuth::AuthHash.new(gender: gender)
        )
      )
    end

    context "when user exists with authentication matching provider & UID" do
      let(:user) { FactoryGirl.create(:user, :with_google, email: email) }

      it "finds user with matching google uid" do
        User.find_from_omniauth(auth_hash)
        expect(user).to be
      end
    end

    context "when user exists with matching email" do
      before :each do
        FactoryGirl.create(:user, email: email)
      end

      it "finds user with matching email" do
        expect(User.find_from_omniauth(auth_hash)).to be
      end

      it "creates an authentication record for the user" do
        user = User.find_from_omniauth(auth_hash)
        expect(user.authentications.where(provider: provider, uid: uid)).to be
      end
    end

    context 'when no user exists' do
      it 'returns nil' do
        expect(User.find_from_omniauth(auth_hash)).to be_nil
      end
    end

  end

  describe "#create_from_omniauth" do
    let(:email) { 'testy@example.gov' }
    let(:first_name) { 'testy' }
    let(:last_name) { 'tester' }
    let(:gender) { 'female' }
    let(:uid) { '12345' }
    let(:phone) { '987-654-3210' }
    let(:provider) { 'google_oauth2' }
    let(:auth_hash) do
      OmniAuth.config.mock_auth[provider] = OmniAuth::AuthHash.new(
        provider: provider,
        uid: uid,
        info: OmniAuth::AuthHash.new(
          email: email,
          first_name: first_name,
          last_name: last_name,
          phone: phone
        ),
        extra: OmniAuth::AuthHash.new(
          raw_info: OmniAuth::AuthHash.new(gender: gender)
        )
      )
    end

    it 'creates user' do
      expect(User.create_from_omniauth(auth_hash)).to be
    end

    it 'creates a profile' do

    end

    it "creates an authentication record for the user" do
      user = User.create_from_omniauth(auth_hash)
      expect(user.authentications.where(provider: provider, uid: uid)).to be
    end
  end

end
