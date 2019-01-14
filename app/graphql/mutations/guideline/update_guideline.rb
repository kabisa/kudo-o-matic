module Mutations
  class Guideline::UpdateGuideline < BaseMutation
    null true

    argument :guideline_id, ID, required: true, description: 'The ID of the guideline to update'
    argument :name, String, required: true, description: 'The name of the guideline to update'
    argument :kudos, ID, required: true, description: 'The suggest kudos of the guideline to update'

    field :guideline, Types::GuidelineType, null: true
    field :errors, [String], null: false

    def resolve(guideline_id:, name:, kudos:)
      guideline = ::Guideline.find(guideline_id)

      if guideline.update(name: name, kudos: kudos)
        { guideline: guideline, errors: [] }
      else
        { guideline: nil, errors: guideline.errors.full_messages }
      end
    end
  end
end