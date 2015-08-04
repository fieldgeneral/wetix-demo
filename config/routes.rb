Rails.application.routes.draw do
  get 'sessions/new'

  resources :event_owners
  get 'landing/index'
  get 'event_owners' => 'my_event'

  root 'landing#index'

  get 'register' => 'event_owners#new', :as => :register

  get '/login' => 'sessions#new', :as => :login
  get '/logout' => 'sessions#destroy', :as => :logout
  post '/sessions/create' => 'sessions#create'

  match '/event_owners/:action(/:event_owner_id)', controller: 'event_owners', via: [:get, :post]

  post 'custom_user' => 'event_owners#custom_user'

  get '/event_owners/:action(/:event_owner_id)/:type' => "event_owners#buy"

  get 'dashboard' => "event_owners#dashboard"

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
