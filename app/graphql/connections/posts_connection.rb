# frozen_string_literal: true

Connections::PostsConnection = Types::PostType.define_connection do
  name "PostConnection"

  field :totalCount do
    description "Count the number of total posts"

    # define return type
    type types.Int

    resolve ->(obj, _args, _ctx) {
      obj.nodes.count
    }
  end
end
