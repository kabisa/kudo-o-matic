module Mutations
  class Goal::UpdateGoal < BaseMutation
    null true

    argument :name, String, required: true, description: 'The updated name of the goal'
    argument :amount, Int, required: true, description: 'The updated amount of kudos for the goal'
    argument :goal_id, ID, required: true, description: 'The ID of the goal to update'

    field :goal, Types::GoalType, null: true

    def resolve(name:, amount:, goal_id:)
      goal = ::Goal.find(goal_id)

      if goal.update(name: name, amount: amount)
        { goal: goal }
      else
        Util::ErrorBuilder.build_errors(context, goal.errors)
        return
      end
    end
  end
end