module Mutations
  class User::ResetPassword < BaseMutation
    null true

    argument :current_password, String, required: false
    argument :new_password, String, required: false
    argument :new_password_confirmation, String, required: false

    field :user, Types::UserType, null: true

    def resolve(current_password:, new_password:, new_password_confirmation:)
      user = context[:current_user]

      if user.valid_password?(current_password)
        if user.reset_password(new_password, new_password_confirmation)
          { user: user }
        else
          raise GraphQL::ExecutionError, 'New password is not matching, please try again'
        end
      else
        raise GraphQL::ExecutionError, 'Incorrect current password, please try again'
      end
    end
  end
end