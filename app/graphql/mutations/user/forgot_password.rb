module Mutations
  class User::ForgotPassword < BaseMutation
    null true

    argument :credentials, Types::AuthProviderEmailInput, required: false

    field :email, Types::EmailAddress, null: true

    def resolve(credentials:)
      user = ::User.find_by(email: credentials[:email])

      user&.send_reset_password_instructions

      { email: credentials[:email] }
    end
  end
end