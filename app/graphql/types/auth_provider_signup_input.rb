# frozen_string_literal: true

module Types
  AuthProviderSignupInput = GraphQL::InputObjectType.define do
    name "AUTH_PROVIDER_SIGNUP_INPUT"

    argument :name, !types.String
    argument :email, !Types::EmailAddress
    argument :password, !types.String
    argument :password_confirmation, !types.String
  end
end
