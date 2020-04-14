# frozen_string_literal: true

Rails.application.routes.draw do
  mount GraphqlPlayground::Rails::Engine, at: "/graphql/playground", graphql_path: "/graphql"

  root 'application#index'

  post "/graphql", to: "graphql#execute"

  get '/users/auth/slack/callback', to: 'slack#test'
  devise_for :users, controllers: {
      registrations: :registrations
  }

  devise_scope :user do
    get "sign_in", to: "devise/sessions#new"
    get "sign_up", to: "devise/registrations#new"
    get "account", to: "devise/registrations#edit"
    get "sign_out", to: "devise/sessions#destroy"
  end


  get "/:team/feed/:rss_token", to: "feed#index"

  post "/slack", to: 'slack#index'
  post "/slack/register", to: 'slack#register'

  match "*path" => redirect("/"), via: :get
end
