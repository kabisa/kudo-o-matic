# frozen_string_literal: true

module Types
  class ViewerType < Types::BaseObject
    graphql_name 'Viewer'

    field :self, UserType,
          null: false,
          description: 'The current user',
          resolve: ->(obj, _args, _ctx) { obj }
  end
end
