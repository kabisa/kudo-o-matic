RSpec.describe Guideline, type: :model do
  it "should have a valid factory" do
    expect(build(:guideline)).to be_valid
  end

  describe "model validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_least(4).is_at_most(100) }
    it { is_expected.to validate_numericality_of(:kudos).is_greater_than_or_equal_to(1).is_less_than_or_equal_to(1000) }
  end

  describe "model associations" do
    it { is_expected.to belong_to(:team) }
  end
end