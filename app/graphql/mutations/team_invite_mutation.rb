# frozen_string_literal: true

module Mutations
  TeamInviteMutation = GraphQL::ObjectType.define do
    name "TeamInviteMutation"
    description "All TeamInvite related mutations"

    field :acceptInvite, Types::TeamInviteType do
      description "Accept a team invite"
      argument :team_invite_id, !types.ID

      # define return type
      type Types::TeamMemberType

      resolve ->(_obj, args, ctx) do
        if ctx[:current_user].blank?
          raise GraphQL::ExecutionError.new("Authentication required")
        end

        team_invite = TeamInvite.find(args[:team_invite_id])

        return unless team_invite
        return if team_invite.complete?
        return if team_invite.email != ctx[:current_user].email

        team_invite.accept
        team_invite
      end
    end

    field :declineInvite, Types::TeamInviteType do
      description "Decline a team invite"
      argument :team_invite_id, !types.ID

      # define return type
      type Types::TeamInviteType

      resolve ->(_obj, args, ctx) do
        if ctx[:current_user].blank?
          raise GraphQL::ExecutionError.new("Authentication required")
        end

        team_invite = TeamInvite.find(args[:team_invite_id])

        return unless team_invite
        return if team_invite.complete?
        return if team_invite.email != ctx[:current_user].email

        team_invite.decline
        team_invite
      end
    end

    field :createInvite, Types::TeamInviteType do
      description "Create a team invite"
      argument :email, !Types::EmailAddress
      argument :team_id, !types.ID

      # define return type
      type Types::TeamInviteType

      resolve ->(_obj, args, ctx) do
        current_user = ctx[:current_user]
        team = Team.find(args[:team_id])

        if current_user.blank?
          raise GraphQL::ExecutionError.new("Authentication required")
        end

        team_member = TeamMember.where(team: team, user: current_user).first

        if team_member.nil?
          raise GraphQL::ExecutionError.new("Failed to create invite: You are not a member of this team.")
        end

        if team_member.role != 'admin'
          raise GraphQL::ExecutionError.new("Failed to create invite: Permission denied.")
        end

        team_invite = TeamInvite.new(
          email: args[:email],
          team: team
        )

        return team_invite if team_invite.save

        raise GraphQL::ExecutionError, team_invite.errors.full_messages.join(", ")
      end
    end
  end
end
