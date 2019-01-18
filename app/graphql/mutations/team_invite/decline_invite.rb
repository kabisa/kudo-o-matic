module Mutations
  class TeamInvite::DeclineInvite < BaseMutation
    null true

    argument :team_invite_id, ID, required: true, description: 'The ID of the team invite to decline'

    field :team_invite, Types::TeamInviteType, null: true
    field :errors, [String], null: false

    def resolve(team_invite_id:)
      team_invite = ::TeamInvite.find(team_invite_id)

      if team_invite.complete?
        { team_invite: nil, errors: ['This invite is already accepted/declined'] }
      else
        team_invite.decline
        { team_invite: team_invite, errors: [] }
      end
    end
  end
end