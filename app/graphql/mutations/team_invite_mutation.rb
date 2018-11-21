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
  end
end
