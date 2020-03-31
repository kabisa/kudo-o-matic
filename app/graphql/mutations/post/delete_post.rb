module Mutations
  class Post::DeletePost < BaseMutation
    null true

    argument :id, ID, required: true, description: 'The ID of the post you want to delete'

    field :post_id, ID, null: true

    def resolve(id:)
      post = ::Post.find(id)

      if post.destroy
        { post_id: id }
      else
        raise GraphQL::ExecutionError, post.errors.full_messages.join('')
      end
    end
  end
end