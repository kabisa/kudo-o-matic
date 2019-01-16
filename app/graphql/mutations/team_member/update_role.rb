# frozen_string_literal: true

module Mutations
  class TeamMember::UpdateRole < BaseMutation
    null true

    argument :role, Types::TeamMemberRoleEnum, required: true
    argument :user_id, ID, required: true
    argument :team_id, ID, required: true

    field :team_member, Types::TeamMemberType, null: true
    field :errors, [String], null: false

    def resolve(role:, user_id:, team_id:)
      team_member = ::TeamMember.find_by_user_id_and_team_id(user_id, team_id)

      ::Team.check_if_last_team_admin?(team_member)

      if team_member.errors.any?
        { team_member: nil, errors: team_member.errors.full_messages }
      elsif team_member.update(role: role)
        { team_member: team_member, errors: [] }
      else
        { team_member: nil, errors: team_member.errors.full_messages }
      end
    end
  end
end