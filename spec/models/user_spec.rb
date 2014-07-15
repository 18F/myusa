require 'rails_helper'

describe User, :type => :model do
  before do
    @valid_attributes = {
      :email => 'joe@citizen.org',
    }
  end

  describe "#create" do
    subject { User.create!(@valid_attributes) }

    context "when called with valid attributes" do
      it { should be_instance_of User }
      its(:errors) { should be_empty }
      its(:uid)    { should match /[0-9a-f\-]{36}/ }
    end

    context "when called without an email address" do
      subject { User.create(@valid_attributes.reject{|k,v| k == :email }) }
      it "should not create a user without an email" do
        expect(subject.errors).not_to include("I'm sorry, your account hasn't been approved yet.")
        expect(subject.errors).not_to be_empty
      end
    end

    context "when called with an invalid email address" do
      subject { User.create(@valid_attributes.merge(email: 'not_valid')) }
      it "should not create a user without a valid email" do
        expect(subject.errors).not_to include("I'm sorry, your account hasn't been approved yet.")
        expect(subject.errors).not_to be_empty
      end
    end
  end
end
