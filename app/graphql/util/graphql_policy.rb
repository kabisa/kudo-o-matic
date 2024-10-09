# frozen_string_literal: true

module Util
  class GraphqlPolicy
    RULES = {
      #################
      # Mutations
      #################
      Types::MutationType => {

        ### Guideline
        createGuideline: ->(_obj, args, ctx) do
          current_user = ctx[:current_user]
          return false unless current_user.present?

          team = Team.find(args[:team_id])

          current_user.admin? || current_user.admin_of?(team)
        end,
        deleteGuideline: ->(_obj, args, ctx) do
          current_user = ctx[:current_user]
          return false unless current_user.present?

          team = Guideline.find(args[:guideline_id]).team

          current_user.admin? || current_user.admin_of?(team)
        end,
        updateGuideline: ->(_obj, args, ctx) do
          current_user = ctx[:current_user]
          return false unless current_user.present?

          team = Guideline.find(args[:guideline_id]).team

          current_user.admin? || current_user.admin_of?(team)
        end,

        ### Goal
        createGoal: ->(_obj, args, ctx) do
          current_user = ctx[:current_user]
          return false unless current_user.present?

          team = KudosMeter.find(args[:kudos_meter_id]).team

          current_user.admin? || current_user.admin_of?(team)
        end,
        deleteGoal: ->(_obj, args, ctx) do
          current_user = ctx[:current_user]
          return false unless current_user.present?

          team = Goal.find(args[:goal_id]).kudos_meter.team

          current_user.admin? || current_user.admin_of?(team)
        end,
        updateGoal: ->(_obj, args, ctx) do
          current_user = ctx[:current_user]
          return false unless current_user.present?

          team = Goal.find(args[:goal_id]).kudos_meter.team

          current_user.admin? || current_user.admin_of?(team)
        end,

        ### KudosMeter
        createKudosMeter: ->(_obj, args, ctx) do
          current_user = ctx[:current_user]
          return false unless current_user.present?

          team = Team.find(args[:team_id])

          current_user.admin? || current_user.admin_of?(team)
        end,
        deleteKudosMeter: ->(_obj, args, ctx) do
          current_user = ctx[:current_user]
          return false unless current_user.present?

          team = KudosMeter.find(args[:kudos_meter_id]).team

          current_user.admin? || current_user.admin_of?(team)
        end,
        updateKudosMeter: ->(_obj, args, ctx) do
          current_user = ctx[:current_user]
          return false unless current_user.present?

          team = KudosMeter.find(args[:kudos_meter_id]).team

          current_user.admin? || current_user.admin_of?(team)
        end,
        setActiveKudosMeter: ->(_obj, args, ctx) do
          current_user = ctx[:current_user]
          return false unless current_user.present?

          team = Team.find(args[:team_id])

          current_user.admin? || current_user.admin_of?(team)
        end,

        ### Post
        createPost: ->(_obj, args, ctx) do
          team = Team.find(args[:team_id])
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

        ### Team
        createTeam: ->(_obj, args, ctx) { ctx[:current_user].present? },
        removeSlack: ->(_obj, args, ctx) {
          current_user = ctx[:current_user]
          return false unless current_user.present?

          team = Team.find(args[:team_id])

          current_user.admin? || current_user.admin_of?(team)
        },
        updateTeam: ->(_obj, args, ctx) do
          current_user = ctx[:current_user]
          return false unless current_user.present?

          team = Team.find(args[:team_id])

          current_user.admin? || current_user.admin_of?(team)
        end,

        ### TeamInvite
        createTeamInvite: ->(_obj, args, ctx) do
          current_user = ctx[:current_user]
          return false unless current_user.present?

          team = Team.find(args[:team_id])

          current_user.admin? || current_user.admin_of?(team)
        end,
        deleteTeamInvite: ->(_obj, args, ctx) do
          current_user = ctx[:current_user]
          return false unless current_user.present?

          team = TeamInvite.find(args[:team_invite_id]).team

          current_user.admin? || current_user.admin_of?(team)
        end,
        acceptTeamInvite: ->(_obj, args, ctx) do
          team_invite = TeamInvite.find(args[:team_invite_id])
          current_user = ctx[:current_user]
          return false unless current_user.present?

          current_user.admin? || team_invite.email == current_user.email
        end,
        declineTeamInvite: ->(_obj, args, ctx) do
          current_user = ctx[:current_user]
          return false unless current_user.present?

          team_invite = TeamInvite.find(args[:team_invite_id])

          current_user.admin? || team_invite.email == current_user.email
        end,

        ### TeamMember
        deleteTeamMember: ->(_obj, args, ctx) do
          current_user = ctx[:current_user]
          return false unless current_user.present?

          team = TeamMember.find(args[:id]).team

          current_user.admin? || current_user.admin_of?(team)
        end,
        updateTeamMemberRole: ->(_obj, args, ctx) do
          current_user = ctx[:current_user]
          return false unless current_user.present?

          team = Team.find(args[:team_id])

          current_user.admin? || current_user.admin_of?(team)
        end,

        ### User
        resetPassword: ->(_obj, _args, ctx) { ctx[:current_user].present? },
        disconnectSlack: ->(_obj, _args, ctx) { ctx[:current_user].present? },

        ### Vote
        toggleLikePost: ->(_obj, args, ctx) do
          team = Post.find(args[:post_id]).team
          current_user = ctx[:current_user]
          return false unless current_user.present?

          current_user.admin? || current_user.member_of?(team)
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

          same_teams = (user.teams && current_user.teams)

          if same_teams.any?
            same_teams.each { |team| current_user.admin_of?(team) }
          else
            current_user.id == user.id || current_user.admin?
          end
        end
      }
    }.freeze

    def self.guard(type, field)
      # RULES.dig(type.metadata[:type_class], field)
      RULES.dig(type.type_class, field.name.to_sym)
    end
  end
end