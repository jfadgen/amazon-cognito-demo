Rails.application.routes.draw do
  root "accounts#index"

  resources :accounts, only: [:index, :create] do
    collection do
      get 'welcome'
      get 'unauthorized'
      get 'sign_out'
    end
  end

  resources :auth, only: [:index] do

  end

  get :admin, :to => 'admin/accounts#index'
  namespace :admin do
    resources :accounts, only: [:index, :show, :create] do
      post 'change_password'
    end
  end
end
