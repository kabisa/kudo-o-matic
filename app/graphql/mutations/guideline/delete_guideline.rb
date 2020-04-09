module Mutations
  class Guideline::DeleteGuideline < BaseMutation
    null true

    argument :guideline_id, ID, required: true, description: 'The ID of the guideline to delete'

    field :guideline_id, ID, null: true

    def resolve(guideline_id:)
      guideline = ::Guideline.find(guideline_id)

      if guideline.destroy
        { guideline_id: guideline.id }
      else
        Util::ErrorBuilder.build_errors(context, guideline.errors)
        return
      end
    end
  end
end