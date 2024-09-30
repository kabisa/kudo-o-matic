# frozen_string_literal: true

module Types
  class ViewerType < Types::BaseObject
    graphql_name 'Viewer'

    field :self, UserType,
          null: false,
          description: 'The current user',
          resolver_method: :resolve_current_user
          # resolve: ->(obj, _args, _ctx) { obj }

    def resolve_current_user
      context[:current_user]
    end
  end
end
