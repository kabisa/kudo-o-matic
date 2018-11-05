# frozen_string_literal: true

class Functions::FindAll < GraphQL::Function
  attr_reader :model_class

  def initialize(model_class)
    @model_class = model_class
  end

  description "Retrieve all resources"

  def call(_obj, args, _ctx)
    result = @model_class.all
    return result if args.keys.empty?

    result = result.order(args[:order]) if args[:order]
    result = result.where("name LIKE?", args[:find_by_name]) if args[:find_by_name]

    result
  end
end
