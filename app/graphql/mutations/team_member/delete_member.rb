# frozen_string_literal: true

module Mutations
  class TeamMember::DeleteMember < BaseMutation
    null true

    argument :id, ID, required: true, description: 'The team member id of the member that gets deleted'

    field :team_member_id, ID, null: true

    def resolve(id:)
      team_member = ::TeamMember.find(id)

      if team_member.destroy
        { team_member_id: team_member.id }
      else
        return Util::ErrorBuilder.build_errors(context, team_member.errors)
      end
    end
  end
end