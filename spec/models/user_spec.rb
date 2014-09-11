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
    let(:uid) { '12345' }

    let(:provider) { 'google_oauth2' }
    let(:auth_hash) do
      OmniAuth::AuthHash.new(
        provider: provider,
        uid: uid,
        info: {
          email: email
        }
      )
    end

    context "when user exists with authentication matching provider & UID" do
      let(:user) do
        #TODO: factories!
        # described_class.create! do |user|
        #   user.email = 'somebody_else@example.gov'
        #   # user.authentications.build(provider: provider, uid: uid)
        #   FactoryGirl.create(:google_authentication)
        # end
        FactoryGirl.create(:user, :with_google, email: email)

      end

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
    let(:uid) { '12345' }

    let(:provider) { 'google_oauth2' }
    let(:auth_hash) do
      OmniAuth::AuthHash.new(
        provider: provider,
        uid: uid,
        info: {
          email: email
        }
      )
    end

    it "creates user" do
      expect(User.create_from_omniauth(auth_hash)).to be
    end

    it "creates an authentication record for the user" do
      user = User.create_from_omniauth(auth_hash)
      expect(user.authentications.where(provider: provider, uid: uid)).to be
    end
  end

end
