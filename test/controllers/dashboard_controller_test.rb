require "test_helper"

class DashboardControllerTest < ActionController::TestCase

  def test_index
    get :index
    assert_response :success
  end

end
