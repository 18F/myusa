class AddOauth2ProviderModels < ActiveRecord::Migration
  def up
    Songkick::OAuth2::Model::Schema.migrate
  end
end
