# frozen_string_literal: true

Rails.application.routes.draw do
  mount GraphqlPlayground::Rails::Engine, at: "/graphql/playground", graphql_path: "/graphql"

  root 'application#index'

  post "/graphql", to: "graphql#execute"

  devise_for :users, controllers: {
      registrations: :registrations
  }


  get "/:team/feed/:rss_token", to: "feed#index"

  get 'auth/slack/:team_id', to: 'slack#auth'
  get 'auth/callback/slack/:team_id', to: 'slack#auth_callback'
  post "/slack/kudo", to: 'slack#give_kudos'
  post "/slack/guidelines", to: 'slack#guidelines'
  post "/slack/register", to: 'slack#register'

  match "*path" => redirect("/"), via: :get
end
