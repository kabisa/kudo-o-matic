module Mutations
  class TeamInvite::AcceptInvite < BaseMutation
    null true

    argument :team_invite_id, ID, required: true, description: 'The ID of the team invite to accept'

    field :team_invite, Types::TeamInviteType, null: true

    def resolve(team_invite_id:)
      team_invite = ::TeamInvite.find(team_invite_id)

      if team_invite.complete?
        raise GraphQL::ExecutionError, 'This invite is already accepted/declined'
      else
        team_invite.accept
        { team_invite: team_invite }
      end
    end
  end
end