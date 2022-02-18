Rails.application.routes.draw do
  root "accounts#index"

  resources :accounts, only: [:index, :create] do
    collection do
      get 'welcome'
      get 'unauthorized'
      delete 'sign_out'
    end
  end

  resources :auth, only: [:index] do

  end
end
