# frozen_string_literal: true

Rails.application.routes.draw do
  if Rails.env.development?
    mount GraphQL::Playground::Engine, at: "/graphql/playground", graphql_path: "/graphql"
  end

  root 'application#index'

  post "/graphql", to: "graphql#execute"

  devise_for :users, controllers: {
      registrations: :registrations
  }


  get "/:team/feed/:rss_token", to: "feed#index"

  get 'auth/slack/user/:user_id', to: 'slack#auth_user'
  get 'auth/slack/team/:team_id', to: 'slack#auth_team'
  get 'auth/callback/slack/team/:team_id', to: 'slack#team_auth_callback'
  get 'auth/callback/slack/user/:user_id', to: 'slack#user_auth_callback'
  post "/slack/kudo", to: 'slack#give_kudos'
  post "/slack/guidelines", to: 'slack#guidelines'
  post "/slack/event", to: "slack#event"

  match '*path' => redirect("/"), via: :get, constraints: lambda { |req|
    req.path.exclude? 'rails/active_storage'
  }
end
