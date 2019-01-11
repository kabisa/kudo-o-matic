# frozen_string_literal: true

module Types
  class AuthenticateType < BaseObject
    graphql_name "Authenticate"

    field :token, String, null: true
    field :user, Types::UserType, null: true
  end
end
