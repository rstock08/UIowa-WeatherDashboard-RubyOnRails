Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'
  
  root 'metrics#index'
  match '/metrics/rank', to: 'metrics#rank', via: :post
  match '/metrics/rate', to: 'metrics#rate', via: :post
  match '/weather', to: 'weather#index', via: :get
  match '/weather/search', to: 'weather#search', via: :get
  match '/weather/show', to: 'weather#show', via: :get
  match '/weather/filter', to: 'weather#filter', via: :get
  match '/metrics', to: 'metrics#index', via: :get
  resources :weather_locations
  resources :notifications
  
  resources :users
  
  match '/login', to: 'sessions#new', via: :get
  match '/login', to: 'sessions#request_password', via: :post
  match '/weather', to: 'sessions#update_password', via: :post
  match '/login_create', to: 'sessions#create', via: :post
  match '/logout', to: 'sessions#destroy', via: :delete
  match '/forgot_password', to: 'sessions#forgot_password', via: :get
  match '/change_password', to: 'sessions#change_password', via: :get

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
