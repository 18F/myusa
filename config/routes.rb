require 'api_constraints'

Rails.application.routes.draw do
  
  get "redesign" => "redesign#index"

  root to: "home#index"
  get "legal" => "home#legal"
  get 'developer' => 'home#developer'
  post 'contact_us' => 'home#contact_us'

  # Legacy implementation used POST /oauth/authorize for both the user facing
  # authorization screen and the API endpoint to request a token ... so, we have
  # to support it. Set this route before the `use_doorkeeper` call so that this
  # route takes precedence over the other doorkeeper routes.
  post '/oauth/authorize' => 'doorkeeper/tokens#create', constraints: ->(req) {
    req.params['grant_type'] == 'authorization_code'
  }

  use_doorkeeper do
    skip_controllers :applications
    controllers authorizations: 'oauth/authorizations',
                authorized_applications: 'oauth/authorized_applications'
  end

  get 'authorizations' => 'oauth/authorized_applications#index'

  # Pull this out of the `use_doorkeeper` block so that we can put it at the
  # root level.
  # resources :applications, only: %w(new create show edit update destroy), as: 'oauth_applications'
  resources :applications, as: 'oauth_applications'

  post 'new_api_key' => 'applications#new_api_key'
  post 'make_public' => 'applications#make_public'

  devise_for :users,
    controllers: {
      omniauth_callbacks: "omniauth_callbacks" ,
      sessions: "sessions"
    }

  devise_scope :user do
    resource :user, only: [:update]
    get 'users/sign_in/:token_id' => 'sessions#show', as: 'user_session_token'

    namespace :users do
      namespace :factors do
        resource :sms
      end
    end
  end

  resource :mobile_recovery
  get 'mobile_recovery/cancel' => 'mobile_recoveries#cancel'
  get 'mobile_recovery/welcome' => 'mobile_recoveries#welcome'

  get 'settings/notifications' => 'notification_settings#index'
  post 'settings/notifications' => 'notification_settings#update'

  get 'unsubscribe/:delivery_method', to: 'unsubscribe#unsubscribe', as: 'unsubscribe'

  resource :profile, only: [:show, :edit, :additional, :update, :destroy] do
    get :additional
  end

  get 'settings/account_settings' => 'settings#account_settings'

  get 'admin' => 'admin#index'

  namespace :api, defaults: {format: :json} do
    namespace :v1, as: 'v1' do
      resource :profile, only: [:show]
      resources :notifications, only: [:create]
      resources :tasks do
        resources :task_items
      end

      get 'tokeninfo', to: '/doorkeeper/token_info#show'
    end

    # For legacy reasons, we translate any API request without a version
    # in the path as a version 1 request.
    # e.g. `/api/STUFF` -> `/api/v1/STUFF`
    # Alas, I haven't found a better way of doing that translation than route
    # duplication. -- Yoz
    scope module: 'v1' do
      resource :profile, only: [:show]
      resources :notifications, only: [:create]
      resources :tasks do
        resources :task_items
      end
    end
  end

  get '/404' => 'errors#not_found'
  get '/422' => 'errors#unprocessable_entity'
end
