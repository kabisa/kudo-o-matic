# frozen_string_literal: true

module Mutations
  PostMutation = GraphQL::ObjectType.define do
    name "PostMutation"
    description "All post related mutations"

    field :createPost, Types::PostType do
      description "Create a new post"
      argument :message, types.String, 'The reason you are giving kudos'
      argument :amount, types.Int, 'The amount of kudos you want to give'
      argument :receiver_ids, types[types.ID], 'The existing users'
      argument :null_receivers, types[types.String], 'The non-existing users'
      argument :team_id, types.ID, 'The team the post belongs to'

      # define return type
      type Types::PostType

      resolve ->(_obj, args, ctx) do
        if ctx[:current_user].blank?
          raise GraphQL::ExecutionError.new("Authentication required")
        end

        team = Team.find(args[:team_id])

        receivers = []

        receiver_ids = args[:receiver_ids]

        unless receiver_ids.blank?
          receiver_ids.each do |receiver|
            receivers << User.find(receiver)
          end
        end

        null_receivers = args[:null_receivers]

        unless null_receivers.blank?
          null_receivers.each do |receiver|
            user = User.new(
              name: receiver,
              virtual_user: true
            )

            user.save

            team.add_member(user)

            receivers << user
          end
        end

        post = Post.new(
          message: args[:message],
          amount: args[:amount],
          sender: ctx[:current_user],
          receivers: receivers,
          team: team,
          kudos_meter: team.active_kudos_meter
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
