Rails.application.routes.draw do
  root "accounts#index"

  resources :accounts, only: [:index, :create] do
    collection do
      get 'welcome'
      get 'unauthorized'
      get 'sign_out'
      get 'reset_password'
      post 'reset_password', to: 'accounts#send_confirmation_code'
      post 'confirm_reset_password'
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
