module Mutations
  class SignUpUserMutation < BaseMutation
    null true

    argument :credentials, Types::AuthProviderSignupInput, required: false

    field :authenticate_data, Types::AuthenticateType, null: true
    field :errors, [String], null: false

    def resolve(credentials:)
      user = User.new(
        name: credentials[:name],
        email: credentials[:email],
        password: credentials[:password],
        password_confirmation: credentials[:password_confirmation]
      )

      if user.save
        {
          authenticate_data: OpenStruct.new(token: AuthToken.new.token(user), user: user),
          errors: []
        }
      else
        {
          authenticate_data: nil,
          errors: user.errors.full_messages
        }
      end
    end
  end
end