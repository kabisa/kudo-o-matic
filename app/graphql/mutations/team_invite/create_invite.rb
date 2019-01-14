module Mutations
  class TeamInvite::CreateInvite < BaseMutation
    null true

    argument :emails, [Types::EmailAddress], required: true, description: 'The emails that the invites are sent to'
    argument :team_id, ID, required: true, description: 'The team that the invites belong to'

    field :team_invites, [Types::TeamInviteType], null: true
    field :errors, [String], null: false

    def resolve(emails:, team_id:)
      team = ::Team.find(team_id)
      team_invites = []

      emails.uniq.each do |email|
        team_invite = ::TeamInvite.new(
          email: email,
          team: team
        )

        unless team_invite.valid?
          { team_invites: nil, errors: team_invite.errors.full_messages }
        end

        team_invites << team_invite
      end

      ::TeamInvite.transaction do
        team_invites.each(&:save)
        { team_invites: team_invites, errors: [] }
      end
    end
  end
end