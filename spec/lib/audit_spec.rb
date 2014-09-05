require 'spec_helper'

module Audit
  describe ApplicationController, type: :controller do
    class Dummy < ActiveRecord::Base
      audit_on :create
    end

    before :all do
      m = ActiveRecord::Migration
      m.verbose = false
      m.create_table :dummies do |t|
        t.integer :user_id
      end
    end
    after :all do
      m = ActiveRecord::Migration
      m.verbose = false
      m.drop_table :dummies
    end

    controller do
      def index
        sign_in User.find(params[:u])
        Dummy.create!
        render text: 'dummy'
      end
    end

    let(:user) { FactoryGirl.create(:user) }

    before :each do
      get :index, u: user
    end

    it 'audits model creation' do
      expect(user.user_actions.where(record_type: Dummy, action: 'create')).to exist
    end

    it 'audits user sign in' do
      expect(user.user_actions.where(action: 'sign_in')).to exist
    end
  end
end
