require 'spec_helper'
require 'database_dumper'

describe DatabaseDumper do
  after :each do
  	DatabaseDumper.cleanup
  end

  [Doorkeeper::Application, Doorkeeper::AccessGrant, Doorkeeper::AccessToken,
   AuthenticationToken, Authorization, Feedback, Notification, SmsCode, Task, TaskItem, UnsubscribeToken].each do |klass|
  	it "should back up the #{klass.table_name} table" do
  		before = create(klass.to_s.demodulize.underscore)
  		DatabaseDumper.export_all_csvs
  		klass.delete_all
  		DatabaseDumper.import_all_csvs
  		after = klass.first
  		expect(before).to eq(after)
  	end
  end

  it "should back up users and roles correctly" do
    before = create(:admin_user)
    DatabaseDumper.export_all_csvs
    User.delete_all
    Role.delete_all
    DatabaseDumper.import_all_csvs

    after = User.first
    expect(before).to eq(after)
    role = Role.first

    expect(after.roles.count).to eq(1)
    expect(after.roles.first).to eq(role)
    expect(role.users.count).to eq(1)
    expect(role.users.first).to eq(after)
  end

  it "should back up the profiles table" do
  	before = create(:full_profile)
  	DatabaseDumper.export_all_csvs
  	Profile.delete_all
  	DatabaseDumper.import_all_csvs
  	after = Profile.first

  	expect(before).to eq(after)
  end
end
