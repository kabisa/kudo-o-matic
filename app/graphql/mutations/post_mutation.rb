# frozen_string_literal: true

module Mutations
  PostMutation = GraphQL::ObjectType.define do
    name "PostMutation"
    description "All post related mutations"

    field :createPost, Types::PostType do
      description "Create a new post"
      argument :message, !types.String
      argument :amount, !types.Int
      argument :receivers, !types[types.ID]

      # define return type
      type Types::PostType

      resolve ->(_obj, args, ctx) do
        if ctx[:current_user].blank?
          raise GraphQL::ExecutionError.new("Authentication required")
        end

        post = Post.new(
          message: args[:message],
          amount: args[:amount],
          sender: ctx[:current_user],
          receivers: User.find(args[:receivers])
        )

        if post.save
          post
        else
          raise GraphQL::ExecutionError, post.errors.full_messages.join(", ")
        end
      end
    end
  end
end
