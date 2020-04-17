module Mutations
  class Vote::ToggleLikePost < BaseMutation
    null true

    argument :post_id, ID, required: true, description: 'The ID of the post'

    field :post, Types::PostType, null: true

    def resolve(post_id:)
      post = ::Post.find(post_id)
      user = context[:current_user]

      if user.voted_up_on? post
        post.unliked_by(user)
        { post: post }
      else
        post.liked_by(user)
        { post: post }
      end
    end
  end
end