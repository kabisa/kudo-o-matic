module Types
  class GuidelineType < BaseObject
    graphql_name 'Guideline'

    field :id, ID, null: false
    field :name, String,
          null: false,
          description: 'The name of the guideline'
    field :kudos, Int,
          null: false,
          description: 'The amount of kudos that is suggested'
    field :team, Types::TeamType,
          null: false,
          description: 'The team the guideline belongs to',
          resolve: ->(obj, _args, _ctx) { Util::RecordLoader.for(Team).load(obj.team_id) }
  end
end