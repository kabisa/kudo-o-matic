# frozen_string_literal: true

RSpec.describe Goal, type: :model do
  let(:kudos_meter) { create(:kudos_meter) }
  let!(:goal) { create(:goal, kudos_meter: kudos_meter) }

  it "should have a valid factory" do
    expect(build(:goal)).to be_valid
  end

  describe "model validations" do
    # ensure that the name field is never empty
    it { expect(goal).to validate_presence_of(:name) }
    # ensure that the amount field is never empty
    it { expect(goal).to validate_presence_of(:amount) }
  end

  describe "model associations" do
    # ensure that a goal belongs to a kudos_meter
    it { expect(goal).to belong_to(:kudos_meter) }
  end
end
