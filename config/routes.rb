require 'api_constraints'

Rails.application.routes.draw do
  root to: "home#index"
  post 'contact_myusa' => 'home#contact_myusa'

  use_doorkeeper do
    controllers :applications => 'oauth/applications',
                :authorizations => 'oauth/authorizations',
                :authorized_applications => 'oauth/authorized_applications'
  end

  devise_for :users,
    controllers: {
      omniauth_callbacks: "omniauth_callbacks" ,
      sessions: "sessions"
    }

  resource :profile, only: [:show, :edit, :update]


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
