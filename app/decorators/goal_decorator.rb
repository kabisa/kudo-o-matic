# frozen_string_literal: true

class GoalDecorator < Draper::Decorator
  delegate_all

  def name
    object.name.upcase
  end

  def kudos
    h.number_to_kudos(object.amount)
  end
end
