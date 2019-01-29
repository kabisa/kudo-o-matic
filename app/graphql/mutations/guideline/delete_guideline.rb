module Mutations
  class Guideline::DeleteGuideline < BaseMutation
    null true

    argument :guideline_id, ID, required: true, description: 'The ID of the guideline to delete'

    field :guideline_id, ID, null: true
    field :errors, [String], null: false

    def resolve(guideline_id:)
      guideline = ::Guideline.find(guideline_id)

      if guideline.destroy
        { guideline_id: guideline.id, errors: [] }
      else
        { guideline_id: nil, errors: guideline.errors.full_messages }
      end
    end
  end
end