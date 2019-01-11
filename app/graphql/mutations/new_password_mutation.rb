module Mutations
  class NewPasswordMutation < BaseMutation
    null true

    argument :reset_password_token, String, required: false
    argument :password, String, required: false
    argument :password_confirmation, String, required: false

    field :user, Types::UserType, null: true
    field :errors, [String], null: false

    def resolve(reset_password_token:, password:, password_confirmation:)
      user = User.reset_password_by_token(
        reset_password_token: reset_password_token,
        password: password,
        password_confirmation: password_confirmation
      )

      # reset_password_by_token returns a new user if no user is found
      if user.id.nil?
        {
          user: nil,
          errors: user.errors.full_messages
        }
      else
        {
          user: user,
          errors: []
        }
      end
    end
  end
end