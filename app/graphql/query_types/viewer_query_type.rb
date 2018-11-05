# frozen_string_literal: true

module QueryTypes
  ViewerQueryType = GraphQL::ObjectType.define do
    name "ViewerQueryType"
    description "The viewer query type"

    field :viewer, Types::ViewerType, "Viewer of data, current user" do
      resolve ->(_object, _args, context) do
        if context[:current_user].blank?
          raise GraphQL::ExecutionError.new("Authentication required")
        end
        context[:current_user]
      end
    end
  end
end
