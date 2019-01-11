module Queries
  class ViewerQuery < BaseQuery
    type Types::UserType, null: true
    description 'Viewer of data, current user'

    def resolve(**kwargs)
      context[:current_user]
    end
  end
end