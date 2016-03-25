require "test_helper"

class DashboardTest < Capybara::Rails::TestCase
  test "shows relevant information" do
    visit root_path

    within '#most-recent' do
      assert_content page, "50𝕂 van JOEP aan HENK voor HET GEVEN VAN EEN LEZING"
    end

    within '#previous-goal' do
      assert_content page, "TENNISSEN"
      assert_content page, "1.000K"
    end

    within '#next-goal' do
      assert_content page, "KARTEN"
      assert_content page, "1.500K"
    end

    within '#progress' do
      assert_content page, "1.324K"
    end
  end
end
