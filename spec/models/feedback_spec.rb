require 'rails_helper'

describe Feedback do
  let(:remote_ip) { '127.0.0.1' }
  let(:other_ip) { '127.0.0.2' }

  describe '#create' do
    context 'per 5 seconds' do
      before :each do
        create(:feedback, remote_ip: remote_ip)
      end

      it 'does not allow more than 1 message per IP' do
        expect { create(:feedback, remote_ip: remote_ip) }.
          to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'allows new messages if IP address is different' do
        expect(create(:feedback, remote_ip: other_ip)).to be_truthy
      end
    end

    context 'per >5 seconds' do
      before :each do
        build(
          :feedback,
          remote_ip: remote_ip,
          created_at: 10.seconds.ago
        ).save(validate: false)
      end

      it 'allows more than one message per IP' do
        expect(create(:feedback, remote_ip: remote_ip)).to be_truthy
      end
    end

    context 'per day' do
      before :each do
        Feedback::RATE_LIMIT_PER_DAY.times do |i|
          build(
            :feedback,
            remote_ip: remote_ip,
            created_at: (i + 1).hours.ago
          ).save(validate: false)
        end
      end

      it "limits one IP to #{Feedback::RATE_LIMIT_PER_DAY} messages" do
        expect { create(:feedback, remote_ip: remote_ip) }.
          to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'per >1 day' do
      before :each do
        Feedback::RATE_LIMIT_PER_DAY.times do |i|
          create(
            :feedback,
            remote_ip: remote_ip,
            created_at: (24 + i).hours.ago
          )
        end
      end

      it "limits one IP to #{Feedback::RATE_LIMIT_PER_DAY} messages" do
        expect(create(:feedback, remote_ip: remote_ip)).to be_truthy
      end
    end
  end
end
