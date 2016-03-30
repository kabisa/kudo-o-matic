require "test_helper"

class DashboardControllerTest < ActionController::TestCase

  def test_index
    get :index
    assert_response :success

    assert_equal goals(:tennis), assigns(:previous)
    assert assigns(:previous).decorated_with?(GoalDecorator)

    assert_equal goals(:karten), assigns(:next)
    assert assigns(:next).decorated_with?(GoalDecorator)

    assert_equal balances(:current), assigns(:balance)
    assert assigns(:balance).decorated_with?(BalanceDecorator)
  end

end
