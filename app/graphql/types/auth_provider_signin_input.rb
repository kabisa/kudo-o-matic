# frozen_string_literal: true

module Types
  AuthProviderSigninInput = GraphQL::InputObjectType.define do
    name "AUTH_PROVIDER_SIGNIN_INPUT"

    argument :email, !types.String
    argument :password, !types.String
  end
end
