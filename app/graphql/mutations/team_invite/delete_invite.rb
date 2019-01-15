module Mutations
  class TeamInvite::DeleteInvite < BaseMutation
    null true

    argument :team_invite_id, ID, required: true, description: 'The ID of the team invite to delete'

    field :team_invite_id, ID, null: true
    field :errors, [String], null: false

    def resolve(team_invite_id:)
      team_invite = ::TeamInvite.find(team_invite_id)

      if team_invite.destroy
        { team_invite_id: team_invite.id, errors: [] }
      else
        team_invite.decline
        { team_invite_id: nil, errors: team_invite.errors.full_messages }
      end
    end
  end
end