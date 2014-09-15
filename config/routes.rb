require 'api_constraints'

Rails.application.routes.draw do
  root to: "home#index"
  get "legal" => "home#legal"
  post 'contact_us' => 'home#contact_us'

  use_doorkeeper do
    skip_controllers :applications
    controllers authorizations: 'oauth/authorizations',
                authorized_applications: 'oauth/authorized_applications'
  end

  # Pull this out of the `use_doorkeeper` block so that we can put it at the
  # root level.
  resources :applications, as: 'oauth_applications'

  post 'new_api_key' => 'applications#new_api_key'
  post 'make_public' => 'applications#make_public'

  devise_for :users,
    controllers: {
      omniauth_callbacks: "omniauth_callbacks" ,
      sessions: "sessions"
    }

  devise_scope :user do
    get 'users/sign_in/:token_id' => 'sessions#show', as: 'user_session_token'
  end

  resource :mobile_recovery
  get 'mobile_recovery/cancel' => 'mobile_recoveries#cancel'
  get 'mobile_recovery/resend' => 'mobile_recoveries#resend'

  resource :profile, only: [:show, :edit, :update, :destroy] do
    get :delete_account
  end

  namespace :api, defaults: {format: :json} do
    namespace :v1, as: 'v1' do
      resource :profile, only: [:show]
      resources :notifications, only: [:create]
      resources :tasks, only: [:index, :create, :show, :update]
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
      resources :tasks, only: [:index, :create, :show, :update]
    end
  end
end
