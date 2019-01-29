module Mutations
  class Goal::DeleteGoal < BaseMutation
    null true

    argument :goal_id, ID, required: true, description: 'The ID of the goal to delete'

    field :goal_id, ID, null: true
    field :errors, [String], null: false

    def resolve(goal_id:)
      goal = ::Goal.find(goal_id)

      if goal.destroy
        { goal_id: goal.id, errors: [] }
      else
        { goal_id: nil, errors: goal.errors.full_messages }
      end
    end
  end
end