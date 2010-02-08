Crm::Application.routes.draw do
  match '/logout' => 'sessions#destroy', :as => :logout
  match '/login' => 'sessions#new', :as => :login
  resources :users
  resources :houses do
    collection do
      post :check
    end
  end

  resources :streets do
    collection do
      post :auto_complete
    end
  end

  resources :customers do
    collection do
      post :find_or_create
      post :auto_complete
    end
    member do
      post :billing_info
      post :router_info
    end
  end

  resources :tickets do
    collection do
  get :assigned_to_me
  get :only_new
  post :find
  get :closed
  get :new_request
  get :all
  get :mine
  get :new_tariff_change
  end
    member do
  post :add_comment
  post :reopen
  post :redirect
  post :close
  post :accept
  end

  end

  resource :session
  resources :depts
  match '/' => 'welcome#index'
  match '/:controller(/:action(/:id))'
end
