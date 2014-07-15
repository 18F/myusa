require 'rails_helper'

describe User, :type => :model do

  it { should have_one :profile }
  it { should validate_presence_of :uid }
  it { should validate_uniqueness_of :uid }

  describe "#create" do
    before do
      @valid_attributes = {
        :email => 'joe@citizen.org',
      }
    end

    context "created with valid attributes" do
      subject      { User.create!(@valid_attributes) }
      it           { should be_instance_of User }
      it           { should be_valid }
      its(:errors) { should be_empty }
      its(:uid)    { should match /[0-9a-f\-]{36}/ }
    end

    context "created without an email address" do
      subject      { User.create(@valid_attributes.reject{|k,v| k == :email }) }
      it           { should_not be_valid }
      its(:errors) { should_not include("I'm sorry, your account hasn't been approved yet.") }
      its(:errors) { should_not be_empty }
    end

    context "created with an invalid email address" do
      subject      { User.create(@valid_attributes.merge(email: 'not_valid')) }
      it           { should_not be_valid }
      its(:errors) { should_not include("I'm sorry, your account hasn't been approved yet.") }
      its(:errors) { should_not be_empty }
    end
  end
end
