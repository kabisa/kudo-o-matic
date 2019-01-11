# frozen_string_literal: true

module Util
  class GraphqlPolicy
    RULES = {
      #################
      # UserMutations
      #################
      Types::MutationType => {
        resetPassword: ->(_obj, _args, ctx) { ctx[:current_user].present? },
        createTeam: ->(_obj, _args, ctx) { ctx[:current_user].present? },
        createPost: ->(_obj, args, ctx) do
          team = Team.find(args[:teamId])
          current_user = ctx[:current_user]

          return false unless current_user.present?

          current_user.admin? || current_user.member_of?(team)
        end,
        deletePost: ->(_obj, args, ctx) do
          post = Post.find(args[:id])
          current_user = ctx[:current_user]
          return false unless current_user.present?

          if current_user == post.sender || current_user.admin_of?(post.team) || current_user.admin?
            if post.created_at < Post.editable_time
              current_user.admin? || current_user.admin_of?(post.team)
            else
              true
            end
          end
        end,
        toggleLikePost: ->(_obj, args, ctx) do
          team = Post.find(args[:postId]).team
          current_user = ctx[:current_user]
          return false unless current_user.present?

          current_user.admin? || current_user.member_of?(team)
        end,
        createTeamInvite: ->(_obj, args, ctx) do
          team = Team.find(args[:teamId])
          current_user = ctx[:current_user]
          return false unless current_user.present?

          current_user.admin? || current_user.admin_of?(team)
        end,
        acceptTeamInvite: ->(_obj, args, ctx) do
          team_invite = TeamInvite.find(args[:teamInviteId])
          current_user = ctx[:current_user]
          return false unless current_user.present?

          current_user.admin? || team_invite.email == current_user.email
        end,
        declineTeamInvite: ->(_obj, args, ctx) do
          team_invite = TeamInvite.find(args[:teamInviteId])
          current_user = ctx[:current_user]
          return false unless current_user.present?

          current_user.admin? || team_invite.email == current_user.email
        end
      },
      #################
      # Team Type
      #################
      Types::TeamType => {
        '*': ->(obj, _args, ctx) do
          current_user = ctx[:current_user]
          team = obj.object

          current_user.member_of?(team) ||
            current_user.admin?
        end,
        id: ->(obj, _args, ctx) do
          current_user = ctx[:current_user]
          team = obj.object

          TeamInvite.where(team: team, email: current_user.email).any? ||
            current_user.member_of?(team) ||
            current_user.admin?
        end,
        name: ->(obj, _args, ctx) do
          current_user = ctx[:current_user]
          team = obj.object

          TeamInvite.where(team: team, email: current_user.email).any? ||
            current_user.member_of?(team) ||
            current_user.admin?
        end
      },
      #################
      # TeamInvite Type
      #################
      Types::TeamInviteType => {
        '*': ->(obj, _args, ctx) do
          current_user = ctx[:current_user]
          team_invite = obj.object

          current_user.email == team_invite.email ||
            current_user.admin_of?(team_invite.team) ||
            current_user.admin?
        end
      },
      #################
      # Post Type
      #################
      Types::PostType => {
        '*': ->(obj, _args, ctx) do
          current_user = ctx[:current_user]
          team = obj.object.team

          current_user.member_of?(team) ||
            current_user.admin?
        end
      },
      #################
      # User Type
      #################
      Types::UserType => {
        'email': ->(obj, _args, ctx) do
          current_user = ctx[:current_user]
          user = obj.object

          current_user.id == user.id ||
            current_user.admin?
        end
      }
    }.freeze

    def self.guard(type, field)
      RULES.dig(type.metadata[:type_class], field)
    end
  end
end