class Doorkeeper::ApplicationScope < ActiveRecord::Base
  self.table_name = 'oauth_application_scopes'
  belongs_to :application

  scope :for_name, lambda { |n| where(name: n) }

  def self.initialize_from_applications
    Doorkeeper::Application.all.each do |app|
      scope_names = Doorkeeper::OAuth::Scopes.from_string(app.read_attribute(:scopes))

      scope_names.all.each do |sn|
        app.application_scopes.for_name(sn).first_or_create!
      end
    end
  end
end