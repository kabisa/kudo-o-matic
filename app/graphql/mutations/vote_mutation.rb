# frozen_string_literal: true

module Mutations
  VoteMutation = GraphQL::ObjectType.define do
    name "VoteMutation"
    description "All vote related mutations"

    field :toggleLikePost, Types::VoteType do
      description "Upvotes a post"
      argument :post_id, !types.ID

      # define return type
      type Types::PostType

      resolve ->(_obj, args, ctx) do
        if ctx[:current_user].blank?
          raise GraphQL::ExecutionError.new("Authentication required")
        end

        user = User.find(ctx[:current_user].id)
        post = Post.find(args[:post_id])

        return unless post

        if user.voted_up_on? post
          post.unliked_by(user)
        else
          post.like_by(user)
        end

        post
      end
    end
  end
end
