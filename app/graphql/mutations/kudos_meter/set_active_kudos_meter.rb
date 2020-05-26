module Mutations
  class KudosMeter::SetActiveKudosMeter < BaseMutation
    null true

    argument :team_id, ID, required: true, description: 'The id of the team'
    argument :kudos_meter_id, ID, required: true, description: 'The team the kudos meter belongs to'

    field :kudos_meter, Types::KudosMeterType, null: true

    def resolve(team_id:, kudos_meter_id:)
      team = ::Team.find(team_id)
      kudos_meter = ::KudosMeter.find(kudos_meter_id)

      team.active_kudos_meter = kudos_meter
      {kudos_meter: kudos_meter}
    end
  end
end