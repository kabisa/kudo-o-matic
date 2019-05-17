# frozen_string_literal: true

Rails.application.routes.draw do
  mount GraphqlPlayground::Rails::Engine, at: "/graphql/playground", graphql_path: "/graphql"

  root 'application#index'

  post "/graphql", to: "graphql#execute"

  devise_for :users, controllers: {
      omniauth_callbacks: "users/omniauth_callbacks",
      registrations: :registrations
  }

  devise_scope :user do
    get "sign_in", to: "devise/sessions#new"
    get "sign_up", to: "devise/registrations#new"
    get "account", to: "devise/registrations#edit"
    get "sign_out", to: "devise/sessions#destroy"
  end

  scope ":team" do
    get "feed/:rss_token", to: "feed#index"
  end

  match "*path" => redirect("/"), via: :get
end
