Rails.application.routes.draw do

  get 'transactions/new'

  # Administrate
  namespace :admin do
    resources :balances
    resources :goals
    resources :transactions
    resources :activities
    resources :users

    root to: "balances#index"
  end

  resources :transactions,
    only: [:new]

  root 'dashboard#index'
end
