module Mutations
  class User::DisconnectSlack < BaseMutation
    null true

    field :user, Types::UserType, null: true

    def resolve()
      user = context[:current_user]

      user.slack_access_token = nil
      user.slack_id = nil

      if user.save
        { user: user }
      else
        return Util::ErrorBuilder.build_errors(context, user.errors)
      end
    end
  end
end