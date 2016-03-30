require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  def test_number_to_kudos
    assert_equal "2 ₭", number_to_kudos(2)
    assert_equal "42 ₭", number_to_kudos(42)
    assert_equal "867 ₭", number_to_kudos(867)
    assert_equal "5.000 ₭", number_to_kudos(5000)
    assert_equal "2.000.000 ₭", number_to_kudos(2000000)
  end
end

