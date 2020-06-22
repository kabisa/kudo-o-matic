module Mutations
  class User::SignIn < BaseMutation
    null true

    argument :credentials, Types::AuthProviderSigninInput, required: true

    field :authenticate_data, Types::AuthenticateType, null: true

    def resolve(credentials:)
      user = ::User.find_by(email: credentials[:email])

      if user.nil?
        raise GraphQL::ExecutionError, 'Incorrect username/password, please try again'
      elsif user.valid_password?(credentials[:password])
        { authenticate_data: OpenStruct.new(token: AuthToken.new.token(user), user: user) }
      else
        raise GraphQL::ExecutionError, 'Incorrect username/password, please try again'
      end
    end
  end
end