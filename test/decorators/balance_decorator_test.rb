require 'test_helper'

class BalanceDecoratorTest < Draper::TestCase

  def balance
    balances(:current).decorate
  end

  def test_kudos
    assert_equal "1.342 ₭", balance.kudos
  end

  def test_percentage
    # previous: 1000
    # next: 1500
    # current: 1342
    # percentage: (current - previous) / (next - previous) * 100

    assert_equal 68, balance.percentage
  end

end
