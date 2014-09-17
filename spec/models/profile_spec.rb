require 'spec_helper'

describe Profile do
  let(:user) { FactoryGirl.create(:user) }
  let(:profile) { user.profile }

  it 'responds to encrypted & unencrypted versions of its methods' do
    p = Profile.new

    # encrypted
    Profile::ENCRYPTED_FIELDS.each do |f|
      expect(p).to respond_to("#{Profile.encrypted_column_prefix}#{f}".to_sym)
    end

    # unencrypted
    Profile::ENCRYPTED_FIELDS.each do |f|
      expect(p).to respond_to(f)
    end
  end

  it 'encrypts sensitive fields defined in the ENCRYPTED_FIELDS constant' do
    profile = create(:full_profile)
    Profile::ENCRYPTED_FIELDS.each do |f|
      expect(profile.send(f.to_sym)).to_not eq profile.send("#{Profile.encrypted_column_prefix}#{f}".to_sym)
    end
  end

  describe '#attribute_from_scope' do
    it 'returns attribute symbol from valid profile scope' do
      expect(Profile.attribute_from_scope('profile.email')).to eq(:email)
    end

    it 'returns nil for invalid profile scope' do
      expect(Profile.attribute_from_scope('profile.foobar')).to be_nil
    end

    it 'returns nil for non-profile scope' do
      expect(Profile.attribute_from_scope('notifications')).to be_nil
    end
  end

  describe '#mobile_number_confirmed?' do
    before :each do
      profile.update_attributes(mobile_number: '415-555-3455')
      allow(SmsWrapper.instance).to receive(:send_message)
      profile.create_mobile_confirmation.confirm!
    end

    it 'is true if profile has a confirmed mobile_confirmation object' do
      expect(profile).to be_mobile_number_confirmed
    end

    it 'is false when mobile is updated' do
      profile.update_attributes(mobile_number: '415-555-3456')
      expect(profile.reload).to_not be_mobile_number_confirmed
    end
  end

  it "strips dashes out of phone numbers" do
    profile_with_phone = create(:full_profile, phone_number: '123-456-7890')
    expect(profile_with_phone.phone).to eq '1234567890'

    profile_with_mobile = create(:profile, mobile_number: '123-456-7890')
    expect(profile_with_mobile.mobile).to eq '1234567890'
  end

  it "strips dashes out of phone numbers on updates" do
    profile_with_phone = create(:profile, phone_number: '123-456-7890')
    profile_with_phone.update_attributes(phone_number: '123-567-4567', mobile_number: '3-45-678-9012')

    expect(profile_with_phone.phone).to eq '1235674567'
    expect(profile_with_phone.mobile).to eq '3456789012'
  end

  it "rejects zip codes that aren't five digits" do
    profile = build(:profile, zip: "Bad Zip Example")

    expect{profile.save!}.to raise_error(ActiveRecord::RecordInvalid)
    expect(profile.id).to be_nil
    expect(profile.errors.messages[:zip]).to eq ["should be in the form 12345"]
  end

  describe "as_json" do
    let(:user) { FactoryGirl.create(:user, profile: FactoryGirl.create(:full_profile)) }
    let(:fields) { [:first_name, :last_name, :email, :phone_number, :gender, :mobile_number] }
    let(:profile_hash) do
      fields.each_with_object({}) { |f, h| h[f.to_s] = user.profile.send f }
    end

    context "when called without any parameters" do
      it "outputs the full profile in JSON" do
        json = user.profile.as_json
        expect(json).to include profile_hash
      end
    end

    context "when called with a set of specific profile scopes" do
      let(:json) { user.profile.as_json(scope_list: scope_list) }
      let(:scope_list) { ["profile.first_name", "profile.email", "profile.mobile_number"] }
      let(:fields) { [:first_name, :email, :mobile_number] }

      it "only includes information allowed by the scopes" do
        expect(json).to eql profile_hash
      end
    end
  end
end
