module Mutations
  class TeamInvite::DeleteInvite < BaseMutation
    null true

    argument :team_invite_id, ID, required: true, description: 'The ID of the team invite to delete'

    field :team_invite_id, ID, null: true

    def resolve(team_invite_id:)
      team_invite = ::TeamInvite.find(team_invite_id)

      if team_invite.destroy
        { team_invite_id: team_invite.id }
      else
        team_invite.decline
        return Util::ErrorBuilder.build_errors(context, team_invite.errors)
      end
    end
  end
end