# frozen_string_literal: true

module Mutations
  UserMutation = GraphQL::ObjectType.define do
    name "UserMutation"
    description "All user related mutations"

    field :createUser, Types::UserType do
      description "Create a new user"
      argument :credentials, !Types::AuthProviderSignupInput

      # define return type
      type Types::AuthenticateType

      resolve ->(_obj, args, _ctx) do
        user = User.new(
          name: args[:credentials][:name],
          email: args[:credentials][:email],
          password: args[:credentials][:password],
          password_confirmation: args[:credentials][:password_confirmation]
        )

        if user.save
          OpenStruct.new(
            token: AuthToken.new.token(user),
            user: user
          )
        else
          raise GraphQL::ExecutionError, user.errors.full_messages.join(", ")
        end
      end
    end

    field :signInUser, Types::UserType do
      description "Sign in a user"
      # define the arguments this field will receive
      argument :credentials, !Types::AuthProviderSigninInput

      # define what this field will return
      type Types::AuthenticateType

      # resolve the field's response
      resolve ->(_obj, args, _ctx) do
        input = args[:credentials]
        return unless input

        user = User.find_by(email: input[:email])
        return unless user
        return unless user.valid_password?(input[:password])

        OpenStruct.new(
          token: AuthToken.new.token(user),
          user: user
        )
      end
    end
  end
end
