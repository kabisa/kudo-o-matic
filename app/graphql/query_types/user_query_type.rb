# frozen_string_literal: true

module QueryTypes
  UserQueryType = GraphQL::ObjectType.define do
    name "UserQueryType"
    description "The user query type"

    # Retrieve all users
    field :users, types[Types::UserType], function: Functions::FindAll.new(User) do
      argument :findByName, types.String, "Find users by name"
    end

    # find user by id
    field :userById, Types::UserType, function: Functions::FindById.new(User)
  end
end
