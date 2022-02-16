Rails.application.routes.draw do
  root "accounts#index"

  get 'auth/index'
  get 'accounts/index'
  post 'accounts/index'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
end
