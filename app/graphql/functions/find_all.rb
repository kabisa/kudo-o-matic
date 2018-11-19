# frozen_string_literal: true

class Functions::FindAll < GraphQL::Function
  attr_reader :model_class

  def initialize(model_class)
    @model_class = model_class
  end

  description "Retrieve all resources with optional arguments"

  argument :orderBy, types.String, "Column to order the results by"

  def call(_obj, args, _ctx)
    result = @model_class.all
    return result if args.keys.empty?

    result = result.order(args[:orderBy]) if args[:orderBy]
    result = result.where("name LIKE?", args[:findByName]) if args[:findByName]
    result = result.where(team_id: args[:findByTeamId]) if args[:findByTeamId]

    result
  end
end
