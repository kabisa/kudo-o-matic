module Mutations
  class KudosMeter::DeleteKudosMeter < BaseMutation
    null true

    argument :kudos_meter_id, ID, required: true, description: 'The ID of the kudos meter to delete'

    field :kudos_meter_id, ID, null: true
    field :errors, [String], null: false

    def resolve(kudos_meter_id:)
      kudos_meter = ::KudosMeter.find(kudos_meter_id)

      if kudos_meter.destroy
        { kudos_meter_id: kudos_meter.id, errors: [] }
      else
        { kudos_meter_id: nil, errors: kudos_meter.errors.full_messages }
      end
    end
  end
end