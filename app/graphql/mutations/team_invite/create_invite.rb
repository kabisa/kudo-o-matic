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

      error_messages = []
      
      ::TeamInvite.transaction do
        team_invites.each do |team_invite|
          next if team_invite.save
           
          if team_invite.errors.any?
            error_messages << team_invite.errors.full_messages.join(', ')
          end
        end

        if error_messages.empty?
          { team_invites: team_invites, errors: [] }
        else
          raise GraphQL::ExecutionError, error_messages.join(', ')
        end

      end
    end
  end
end