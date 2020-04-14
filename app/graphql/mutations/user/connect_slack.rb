module Mutations
  class User::ConnectSlack < BaseMutation

    field :user, Types::UserType, null: true

    def resolve
      user = context[:current_user]

      user.regenerate_unlock_token
      if user.save
        { user: user }
      else
        Util::ErrorBuilder.build_errors(context, team_member.errors)
        return
      end
    end
  end
end
