require 'test_helper'

class GoalDecoratorTest < Draper::TestCase

  def goal
    goals(:tennis).decorate
  end

  def test_name
    assert_equal "TENNIS", goal.name
  end

  def test_kudos
    assert_equal "1.000 ₭" , goal.kudos
  end

end
