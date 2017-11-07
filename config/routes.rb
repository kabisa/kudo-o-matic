Rails.application.routes.draw do
  root 'transactions#index'

  resources :transactions, only: [:index, :new, :create]

  post 'like/:id', to: 'transactions#upvote', as: :like
  post 'unlike/:id', to: 'transactions#downvote', as: :unlike

  get :kudo_guidelines, to: 'transactions#kudo_guidelines'
  get 'transactions/:type', to: 'transactions#filter'

  get :activities, to: 'activities#autocomplete_search', as: :activities_autocomplete
  get :users, to: 'users#autocomplete_search', as: :users_autocomplete

  get :settings, to: 'users#edit', as: :user
  patch :settings, to: 'users#update'

  get :feed, to: 'feed#index'

  namespace :admin do
    root 'users#index'

    resources :users, except: :destroy do
      member do
        patch :deactivate
        patch :reactivate
      end
    end

    resources :balances
    resources :goals
    resources :transactions
    resources :activities
    resources :votes
  end

  namespace :api do
    namespace :v1 do
      jsonapi_resources :balances, only: :show do
        collection do
          get :current
        end

        jsonapi_links :transactions, only: :show

        jsonapi_related_resources :transactions, only: :show
      end

      jsonapi_resources :goals, only: :show do
        collection do
          get :next
          get :previous
        end

        jsonapi_link :balance, only: :show

        jsonapi_related_resource :balance, only: :show
      end

      jsonapi_resources :transactions, only: [:index, :show, :create] do
        member do
          put :votes, to: 'transactions#like'
          delete :votes, to: 'transactions#unlike'
        end

        jsonapi_link :sender, only: :show
        jsonapi_link :receiver, only: :show
        jsonapi_link :balance, only: :show

        jsonapi_related_resource :sender, only: :show
        jsonapi_related_resource :receiver, only: :show
        jsonapi_related_resource :balance, only: :show
      end

      jsonapi_resources :users, only: [:index, :show] do
        jsonapi_links :sent_transactions, only: :show
        jsonapi_links :received_transactions, only: :show

        jsonapi_related_resources :sent_transactions, only: :show
        jsonapi_related_resources :received_transactions, only: :show
      end

      post 'authentication/obtain_api_token'
    end
  end

  devise_for :users, controllers: {omniauth_callbacks: 'users/omniauth_callbacks'}

  devise_scope :user do
    get :sign_in, to: 'devise/sessions#new', as: :new_user_session
    get :sign_out, to: 'devise/sessions#destroy', as: :destroy_user_session
  end
end
