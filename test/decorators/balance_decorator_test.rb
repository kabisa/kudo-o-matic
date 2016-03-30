require 'test_helper'

class BalanceDecoratorTest < Draper::TestCase

  def balance
    balances(:current).decorate
  end

  def test_kudos
    assert_equal "1.342 ₭", balance.kudos
  end

end
