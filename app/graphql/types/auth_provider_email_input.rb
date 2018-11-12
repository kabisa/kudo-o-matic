# frozen_string_literal: true

module Types
  AuthProviderEmailInput = GraphQL::InputObjectType.define do
    name "AUTH_PROVIDER_EMAIL_INPUT"

    argument :email, !Types::EmailAddress
  end
end
