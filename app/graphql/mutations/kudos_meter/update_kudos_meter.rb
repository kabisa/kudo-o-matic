module Mutations
  class KudosMeter::UpdateKudosMeter < BaseMutation
    null true

    argument :name, String, required: true, description: 'The name of the kudos meter to update'
    argument :kudos_meter_id, ID, required: true, description: 'The team the kudos meter belongs to'

    field :kudos_meter, Types::KudosMeterType, null: true
    field :errors, [String], null: false

    def resolve(name:, kudos_meter_id:)
      kudos_meter = ::KudosMeter.find(kudos_meter_id)

      if kudos_meter.update(name: name)
        { kudos_meter: kudos_meter, errors: [] }
      else
        { kudos_meter: nil, errors: kudos_meter.errors.full_messages }
      end
    end
  end
end