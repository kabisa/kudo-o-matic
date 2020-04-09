module Mutations
  class Guideline::CreateGuideline < BaseMutation
    null true

    argument :name, String, required: true, description: 'The name of the guideline to create'
    argument :kudos, Int, required: true, description: 'The suggested kudos for the guideline to create'
    argument :team_id, ID, required: true, description: 'The team the guideline belongs to'

    field :guideline, Types::GuidelineType, null: true

    def resolve(name:, kudos:, team_id:)
      guideline = ::Guideline.new(name: name, kudos: kudos, team_id: team_id)

      if guideline.save
        { guideline: guideline }
      else
        Util::ErrorBuilder.build_errors(context, guideline.errors)
        return
      end
    end
  end
end