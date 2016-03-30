require "test_helper"

class TransactionTest < ActiveSupport::TestCase
  def transaction
    @transaction ||= Transaction.new
  end

  def test_valid
    assert transaction.valid?
  end
end
