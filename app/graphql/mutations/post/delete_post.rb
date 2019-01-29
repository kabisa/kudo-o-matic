module Mutations
  class Post::DeletePost < BaseMutation
    null true

    argument :id, ID, required: true, description: 'The ID of the post you want to delete'

    field :post_id, ID, null: true
    field :errors, [String], null: false

    def resolve(id:)
      post = ::Post.find(id)

      if post.destroy
        { post_id: id, errors: [] }
      else
        { post_id: nil, errors: post.errors.full_messages }
      end
    end
  end
end