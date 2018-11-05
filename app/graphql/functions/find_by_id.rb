# frozen_string_literal: true

class Functions::FindById < GraphQL::Function
  attr_reader :model_class

  def initialize(model_class)
    @model_class = model_class
  end

  description "Retrieve resource by ID"
  argument :id, !types.ID, "The id of the resource to retrieve"

  def call(_obj, args, _ctx)
    @model_class.find(args[:id])
  end
end
