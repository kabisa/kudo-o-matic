# frozen_string_literal: true

class GoalReacher
  def self.check!(team)
    if Balance.current(team).amount >= Goal.next(team).amount
      Goal.next(team).achieve!

      GoalMailer.new_goal(Goal.previous(team), team)
    end
  end
end
