module Mutations
  class KudosMeter::CreateKudosMeter < BaseMutation
    null true

    argument :name, String, required: true, description: 'The name of the kudos meter to create'
    argument :team_id, ID, required: true, description: 'The team the kudos meter belongs to'

    field :kudos_meter, Types::KudosMeterType, null: true

    def resolve(name:, team_id:)
      kudos_meter = ::KudosMeter.new(name: name, team_id: team_id)

      if kudos_meter.save
        { kudos_meter: kudos_meter }
      else
        raise GraphQL::ExecutionError, kudos_meter.errors.full_messages.join('')
      end
    end
  end
end