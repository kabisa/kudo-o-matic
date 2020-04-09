module Mutations
  class Goal::DeleteGoal < BaseMutation
    null true

    argument :goal_id, ID, required: true, description: 'The ID of the goal to delete'

    field :goal_id, ID, null: true

    def resolve(goal_id:)
      goal = ::Goal.find(goal_id)

      if goal.destroy
        { goal_id: goal.id }
      else
        Util::ErrorBuilder.build_errors(context, goal.errors)
        return
      end
    end
  end
end