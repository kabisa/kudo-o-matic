# frozen_string_literal: true

module Types
  AuthenticateType = GraphQL::ObjectType.define do
    name "Authenticate"

    field :token, types.String
    field :user, Types::UserType
  end
end
