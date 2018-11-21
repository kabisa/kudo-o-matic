# frozen_string_literal: true

module Types
  AuthenticateEmailType = GraphQL::ObjectType.define do
    name "AuthenticateEmail"

    field :email, Types::EmailAddress
  end
end
