# frozen_string_literal: true

module Mutations
  class TeamMember::UpdateRole < BaseMutation
    null true

    argument :role, Types::TeamMemberRoleEnum, required: true
    argument :user_id, ID, required: true
    argument :team_id, ID, required: true

    field :team_member, Types::TeamMemberType, null: true

    def resolve(role:, user_id:, team_id:)
      team_member = ::TeamMember.find_by_user_id_and_team_id(user_id, team_id)
      team_member.role = role

      if team_member.save
        { team_member: team_member }
      else
        Util::ErrorBuilder.build_errors(context, team_member.errors)
        return
      end
    end
  end
end