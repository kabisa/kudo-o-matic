module Mutations
  class KudosMeter::DeleteKudosMeter < BaseMutation
    null true

    argument :kudos_meter_id, ID, required: true, description: 'The ID of the kudos meter to delete'

    field :kudos_meter_id, ID, null: true

    def resolve(kudos_meter_id:)
      kudos_meter = ::KudosMeter.find(kudos_meter_id)

      if kudos_meter.destroy
        { kudos_meter_id: kudos_meter.id }
      else
        Util::ErrorBuilder.build_errors(context, kudos_meter.errors)
        return
      end
    end
  end
end