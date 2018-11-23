# frozen_string_literal: true

module Mutations
  PostMutation = GraphQL::ObjectType.define do
    name "PostMutation"
    description "All post related mutations"

    field :createPost, Types::PostType do
      description "Create a new post"
      argument :message, !types.String
      argument :amount, !types.Int
      argument :receiver_ids, !types[types.ID]
      argument :team_id, !types.ID

      # define return type
      type Types::PostType

      resolve ->(_obj, args, ctx) do
        if ctx[:current_user].blank?
          raise GraphQL::ExecutionError.new("Authentication required")
        end

        team = Team.find(args[:team_id])

        post = Post.new(
          message: args[:message],
          amount: args[:amount],
          sender: ctx[:current_user],
          receivers: User.find(args[:receiver_ids]),
          team: team,
          kudos_meter: Team.find(args[:team_id]).active_kudos_meter
        )

        if post.save
          PostMailer.new_post(post)
          GoalReacher.check!(team)

          return post
        else
          raise GraphQL::ExecutionError, post.errors.full_messages.join(', ')
        end
      end
    end
  end
end
