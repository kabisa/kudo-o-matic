# frozen_string_literal: true

module Types
  class AuthProviderSignupInput < BaseInputObject
    graphql_name "AUTH_PROVIDER_SIGNUP_INPUT"

    argument :name, String, required: false
    argument :email, Types::EmailAddress, required: false
    argument :password, String, required: false
    argument :password_confirmation, String, required: false
  end
end
