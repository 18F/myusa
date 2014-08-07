require 'api_constraints'

Rails.application.routes.draw do
  root to: "application#index"
  get "secret" => "application#secret"

  use_doorkeeper do
    controllers :applications => 'oauth/applications'
    controllers  :authorizations => 'oauth/authorizations'
  end

  devise_for :users,
    controllers: {
      omniauth_callbacks: "omniauth_callbacks" ,
      sessions: "sessions"
    }

  namespace :api, :defaults => {:format => :json} do
    scope :module => :v1, :constraints => ApiConstraints.new(:version => 1, :default => true) do
      resource :profile, :only => [:show]
      resources :notifications, :only => [:create]
      resources :tasks, :only => [:index, :create, :show, :update]
    end
  end

end
