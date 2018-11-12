module QueryTypes
  GuidelineQueryType = GraphQL::ObjectType.define do
    name 'GuidelineQueryType'
    description 'The guideline query type'

    field :guidelines, types[Types::GuidelineType], function: Functions::FindAll.new(Guideline)

    field :guidelineById, Types::GuidelineType, function: Functions::FindById.new(Guideline)
  end
end