require 'test_helper'

class TransactionDecoratorTest < Draper::TestCase

  def transaction
    transactions(:one).decorate
  end

  def test_to_s
    expected = "1.342 ₭ from HARRY to WILLIAM for WRITING A BLOG POST"
    assert_equal expected, transaction.to_s
  end

end

