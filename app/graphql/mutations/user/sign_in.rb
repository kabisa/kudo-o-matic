module Mutations
  class User::SignIn < BaseMutation
    null true

    argument :credentials, Types::AuthProviderSigninInput, required: true

    field :authenticate_data, Types::AuthenticateType, null: true
    field :errors, [String], null: false

    def resolve(credentials:)
      user = ::User.find_by(email: credentials[:email])

      if user.nil?
        { authenticate_data: nil, errors: ['Incorrect username/password, please try again'] }
      elsif user.valid_password?(credentials[:password])
        { authenticate_data: OpenStruct.new(token: AuthToken.new.token(user), user: user), errors: [] }
      else
        { authenticate_data: nil, errors: ['Incorrect username/password, please try again'] }
      end
    end
  end
end