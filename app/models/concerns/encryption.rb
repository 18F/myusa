require 'active_support/concern'

module Encryption  
  extend ActiveSupport::Concern

  def key
    key_val = Rails.configuration.database_configuration[Rails.env]['encryption_key']
    # if in production. require key to be set.
    if Rails.env.production?
      raise 'Must set token key!!' unless key_val
      key_val
    else
      key_val
    end
  end

  module ClassMethods
    def encrypted_column_prefix
      self::attr_encrypted_options[:prefix] ? self::attr_encrypted_options[:prefix] : 'encrypted_'
    end
  end
end
