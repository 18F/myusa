require 'spec_helper'

describe Profile do
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

  it "strips dashes out of phone numbers" do
    profile_with_phone = create(:full_profile, phone_number: '123-456-7890')
    expect(profile_with_phone.phone).to eq '1234567890'

    profile_with_mobile = create(:profile, mobile_number: '123-456-7890')
    expect(profile_with_mobile.mobile).to eq '1234567890'
  end

  it "strips dashes out of phone numbers on updates" do
    profile_with_phone = create(:profile, phone_number: '123-456-7890')
    profile_with_phone.update(phone_number: '123-567-4567', mobile_number: '3-45-678-9012')
    profile_with_phone.reload

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
    before do
      @user = create_confirmed_user_with_profile
      @user.profile.update_attributes(:phone_number => '202-555-1212', :gender => 'male')
    end

    context "when called without any parameters" do
      it "outputs the full profile in JSON" do
        json = @user.profile.as_json

        expect(json["first_name"]).to eq 'Joe'
        expect(json["last_name"]).to eq 'Citizen'
        expect(json["email"]).to eq 'joe@citizen.org'
        expect(json["phone_number"]).to eq '202-555-1212'
        expect(json["gender"]).to eq 'male'
        expect(json["mobile_number"]).to be_blank
      end
    end

    context "when called with a scope list that includes the profile scope" do
      it "returns the full profile" do
        json = @user.profile.as_json(:scope_list => ["profile", "tasks", "notifications"])
        expect(json["first_name"]).to eq 'Joe'
        expect(json["last_name"]).to eq 'Citizen'
        expect(json["email"]).to eq 'joe@citizen.org'
        expect(json["phone_number"]).to eq '202-555-1212'
        expect(json["gender"]).to eq 'male'
        expect(json["mobile_number"]).to be_blank
      end

      context "and there are other profile scopes as well" do
        it "returns the full profile" do
          json = @user.profile.as_json(:scope_list => ["profile", "tasks", "notifications", "profile.first_name", "profile.gender"])
          expect(json["first_name"]).to eq 'Joe'
          expect(json["last_name"]).to eq 'Citizen'
          expect(json["email"]).to eq 'joe@citizen.org'
          expect(json["phone_number"]).to eq '202-555-1212'
          expect(json["gender"]).to eq 'male'
          expect(json["mobile_number"]).to be_blank
        end
      end
    end

    context "when called with a set of specific profile scopes" do
      it "returns only those profile fields" do
        json = @user.profile.as_json(:scope_list => ["profile.first_name", "profile.email", "profile.mobile_number"])
        expect(json["first_name"]).to eq 'Joe'
        expect(json["last_name"]).to be_nil
        expect(json["email"]).to eq 'joe@citizen.org'
        expect(json["phone_number"]).to be_nil
        expect(json["gender"]).to be_nil
        expect(json["mobile_number"]).to be_blank
      end
    end   
  end
end
