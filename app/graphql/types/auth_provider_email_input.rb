# frozen_string_literal: true

module Types
  class AuthProviderEmailInput < BaseInputObject
    graphql_name "AUTH_PROVIDER_EMAIL_INPUT"

    argument :email, Types::EmailAddress, required: true
  end
end
