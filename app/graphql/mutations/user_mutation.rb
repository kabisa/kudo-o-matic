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

    field :forgotPassword, Types::UserType do
      description "Reset a user's password"

      argument :credentials, !Types::AuthProviderEmailInput

      # define return type
      type Types::AuthenticateEmailType

      resolve ->(_obj, args, _ctx) do
        input = args[:credentials]
        return unless input

        user = User.find_by(email: input[:email])
        return unless user

        user.send_reset_password_instructions
        user
      end
    end

    field :newPassword, Types::UserType do
      description "Create new password if user forgot old one"

      argument :reset_password_token, !types.String
      argument :password, !types.String
      argument :password_confirmation, !types.String

      # define return type
      type Types::UserType

      resolve ->(_obj, args, _ctx) do
        break unless args[:reset_password_token]

        user = User.reset_password_by_token(
          reset_password_token: args[:reset_password_token],
          password: args[:password],
          password_confirmation: args[:password_confirmation]
        )

        # reset_password_by_token returns a new user if no user is found
        user.id.nil? ? break : user
      end
    end
  end
end
