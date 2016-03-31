Rails.application.routes.draw do
  namespace :admin do
    resources :balances
resources :goals
resources :transactions
resources :activities
resources :users

    root to: "balances#index"
  end

  root 'dashboard#index'
end
