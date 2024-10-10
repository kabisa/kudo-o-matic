module Mutations
  class Goal::CreateGoal < BaseMutation
    null true

    argument :name, String, required: true, description: 'The name of the goal to create'
    argument :amount, Int, required: true, description: 'The amount of kudos for the goal to create'
    argument :kudos_meter_id, ID, required: true, description: 'The kudos meter the goal belongs to'

    field :goal, Types::GoalType, null: true

    def resolve(name:, amount:, kudos_meter_id:)
      kudos_meter = ::KudosMeter.find(kudos_meter_id)
      goal = kudos_meter.goals.build(name: name, amount: amount)
      if goal.save
        { goal: goal }
      else
        return Util::ErrorBuilder.build_errors(context, goal.errors)
      end
    end
  end
end