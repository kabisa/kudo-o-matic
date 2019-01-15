# frozen_string_literal: true

module Mutations
  class TeamMember::DeleteMember < BaseMutation
    null true

    argument :id, ID, required: true, description: 'The team member id of the member that gets deleted'

    field :team_member_id, ID, null: true
    field :errors, [String], null: false

    def resolve(id:)
      team_member = ::TeamMember.find(id)
      team = team_member.team

      if team.remove_member(team_member.user)
        { team_member_id: team_member.id, errors: [] }
      else
        { team_member_id: nil, errors: team_member.errors.full_messages }
      end
    end
  end
end