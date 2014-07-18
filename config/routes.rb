require 'api_constraints'

Rails.application.routes.draw do
  root to: "application#index"
  get "secret" => "application#secret"

  devise_for :users,
    controllers: {
      omniauth_callbacks: "omniauth_callbacks" ,
      sessions: "sessions"
    }
  get 'oauth/authorize' => 'oauth#authorize'
  post 'oauth/authorize' => 'oauth#authorize'
  post 'oauth/allow' => 'oauth#allow'
  get 'oauth/unknown_app' => 'oauth#unknown_app', :as => :unknown_app

  namespace :api, :defaults => {:format => :json} do
    scope :module => :v1, :constraints => ApiConstraints.new(:version => 1, :default => true) do
      resource :profile, :only => [:show]
      resources :notifications, :only => [:create]
      resources :tasks, :only => [:index, :create, :show, :update]
    end
  end

end
