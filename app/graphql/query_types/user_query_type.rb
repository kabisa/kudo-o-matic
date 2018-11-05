# frozen_string_literal: true

module QueryTypes
  UserQueryType = GraphQL::ObjectType.define do
    name "UserQueryType"
    description "The user query type"

    # Retrieve all users
    field :users, types[Types::UserType], function: Functions::FindAll.new(User) do
      argument :orderBy, types.String, "Column to order the results by", as: :order
      argument :findByName, types.String, "Find users by name", as: :find_by_name
    end

    # find user by id
    field :userById, Types::UserType, function: Functions::FindById.new(User)
  end
end
