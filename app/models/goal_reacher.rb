# frozen_string_literal: true

class GoalReacher
  def self.check!(team)
    return if Goal.next(team).nil?

    if team.active_kudos_meter.amount >= Goal.next(team).amount
      Goal.next(team).achieve!

      GoalMailer.new_goal(Goal.previous(team), team)
    end
  end
end
