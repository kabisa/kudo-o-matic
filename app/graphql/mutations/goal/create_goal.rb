module Mutations
  class Goal::CreateGoal < BaseMutation
    null true

    argument :name, String, required: true, description: 'The name of the goal to create'
    argument :amount, Int, required: true, description: 'The amount of kudos for the goal to create'
    argument :kudos_meter_id, ID, required: true, description: 'The kudos meter the goal belongs to'

    field :goal, Types::GoalType, null: true
    field :errors, [String], null: false

    def resolve(name:, amount:, kudos_meter_id:)
      goal = ::Goal.new(name: name, amount: amount, kudos_meter_id: kudos_meter_id)

      if goal.save
        { goal: goal, errors: [] }
      else
        { goal: nil, errors: goal.errors.full_messages }
      end
    end
  end
end