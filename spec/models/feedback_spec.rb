require 'rails_helper'

describe Feedback do
  # let(:feedback) { FactoryGirl.build(:feedback) }
  let (:remote_ip) { '127.0.0.1' }
  let (:other_ip) { '127.0.0.2' }

  describe "#create" do
    context 'per 5 seconds' do
      before :each do
        FactoryGirl.create(:feedback, remote_ip: remote_ip)
      end

      it 'does not allow more than 1 message per IP' do
        expect{FactoryGirl.create(:feedback, remote_ip: remote_ip)}.to raise_error(ActiveRecord::RecordInvalid)
      end


      it 'allows new messages if IP address is different' do
        expect(FactoryGirl.create(:feedback, remote_ip: other_ip)).to be_truthy
      end
    end

    context 'per >5 seconds' do
      before :each do
        FactoryGirl.create(:feedback, remote_ip: remote_ip, created_at: Time.now - 10.seconds)
      end

      it 'allows more than one message per IP' do
        expect(FactoryGirl.create(:feedback, remote_ip: remote_ip)).to be_truthy
      end
    end

    context 'per day' do
      before :each do
        10.times do |i|
          FactoryGirl.create(:feedback, remote_ip: remote_ip, created_at: Time.now - (12 + i).hours)
        end
      end

      it 'limits one IP to 10 messages' do
        expect{FactoryGirl.create(:feedback, remote_ip: remote_ip)}.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'per >1 day' do
      before :each do
        10.times do |i|
          FactoryGirl.create(:feedback, remote_ip: remote_ip, created_at: Time.now - (24 + i).hours)
        end
      end

      it 'limits one IP to 10 messages' do
        expect(FactoryGirl.create(:feedback, remote_ip: remote_ip)).to be_truthy
      end
    end
  end
end
