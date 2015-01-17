class AddTimestampsToAuthenticationToken < ActiveRecord::Migration
  def change
    add_column :authentication_tokens, :created_at, :datetime
    add_column :authentication_tokens, :updated_at, :datetime
  end
end
