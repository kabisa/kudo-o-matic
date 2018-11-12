module Types
  GuidelineType = GraphQL::ObjectType.define do
    name 'Guideline'

    field :id, !types.ID, 'The ID of the guideline'
    field :name, !types.String, 'The name of the guideline'
    field :kudos, !types.Int, 'The amount of kudos that is suggested'

    field :team, !Types::TeamType, 'The team the guideline belongs to' do
      resolve ->(obj, args, ctx) { Util::RecordLoader.for(Team).load(obj.team_id) }
    end
  end
end