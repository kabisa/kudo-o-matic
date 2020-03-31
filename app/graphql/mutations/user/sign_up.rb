module Mutations
  class User::SignUp < BaseMutation
    null true

    argument :credentials, Types::AuthProviderSignupInput, required: false

    field :authenticate_data, Types::AuthenticateType, null: true

    def resolve(credentials:)
      user = ::User.new(
        name: credentials[:name],
        email: credentials[:email],
        password: credentials[:password],
        password_confirmation: credentials[:password_confirmation]
      )

      if user.save
        { authenticate_data: OpenStruct.new(token: AuthToken.new.token(user), user: user) }
      else
        raise GraphQL::ExecutionError, user.errors.full_messages.join('')
      end
    end
  end
end