require 'spec_helper'
require 'database_dumper'

describe DatabaseDumper do
  after :each do
  	DatabaseDumper.cleanup
  end

  [Doorkeeper::Application, Doorkeeper::AccessGrant, Doorkeeper::AccessToken,
   AuthenticationToken, Authorization, Feedback, Notification, SmsCode, Task, TaskItem, UnsubscribeToken].each do |klass|
  	it "should back up the #{klass.table_name} table" do
  		before = build(klass.to_s.demodulize.underscore)
      expect(klass.count).to eq 1
  		DatabaseDumper.export_all_csvs
  		klass.delete_all
  		DatabaseDumper.import_all_csvs
  		after = klass.first
  		expect(before).to eq(after)
  	end
  end

  # Fixme: test Roles, Users and habtm

  it "should back up the profiles table" do
  	before = create(:full_profile)
  	DatabaseDumper.export_all_csvs
  	Profile.delete_all
  	DatabaseDumper.import_all_csvs
  	after = Profile.first

  	expect(before).to eq(after)
  end
end
