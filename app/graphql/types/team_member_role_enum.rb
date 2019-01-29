# frozen_string_literal: true

module Types
  class TeamMemberRoleEnum < BaseEnum
    graphql_name 'TeamMemberRole'

    value('member', 'The team member has no extra permissions')
    value('moderator', 'TBD')
    value('admin', 'The team member has all permissions within a team')
  end
end
