require 'api_constraints'

Rails.application.routes.draw do
  root to: "application#index"
  get "secret" => "application#secret"

  devise_for :users,
    # path_names: { sign_up: :sign_in },
    controllers: {
      omniauth_callbacks: "omniauth_callbacks" ,
      sessions: "sessions"
    }


  namespace :api, :defaults => {:format => :json} do
    scope :module => :v1, :constraints => ApiConstraints.new(:version => 1, :default => true) do
      resource :profile, :only => [:show]
      resources :notifications, :only => [:create]
      resources :tasks, :only => [:index, :create, :show, :update]
#      resources :forms, :only => [:create, :show]
#      get "credentials/verify" => "credentials#verify", :as => :verify_credentials
    end
  end

  # resources :users do
  #   collection do
  #     # TODO Investigate why 'Her' is updating without an ID in the URL
  #     put '' => 'users#update' # This supports a 'Her' call where ID is in the body instead of the URL
  #   end
  # end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
