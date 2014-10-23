require 'simple_role/model_mixin'
require 'simple_role/subject_mixin.rb'

module SimpleRole
  class AccessDenied < StandardError; end
end

ActiveRecord::Base.extend(SimpleRole::ModelMixin)
