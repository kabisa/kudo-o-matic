# frozen_string_literal: true

module GoalHelper
  def kudos_to_next_goal(team)
    Goal.next(team).amount - team.active_kudos_meter.amount
  end
end
