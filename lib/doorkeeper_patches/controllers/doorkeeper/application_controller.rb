class Doorkeeper::ApplicationController < ActionController::Base
  include Doorkeeper::Helpers::Controller
  include RolesHelper
end
