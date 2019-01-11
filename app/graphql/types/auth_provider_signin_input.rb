# frozen_string_literal: true

module Types
  class AuthProviderSigninInput < BaseInputObject
    graphql_name "AUTH_PROVIDER_SIGNIN_INPUT"

    argument :email, Types::EmailAddress, required: true
    argument :password, String, required: true
  end
end
