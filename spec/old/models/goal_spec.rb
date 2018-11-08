# frozen_string_literal: true

require "rails_helper"

RSpec.describe Goal, type: :model do
  # Skip the after_create callback in this spec, because we are working with specific kudos_meters and goals
  before do
    Team.skip_callback(:create, :after, :setup_team)
  end

  # After this spec, set the callback again, so other specs can make use of it
  after do
    Team.set_callback(:create, :after, :setup_team)
  end

  context ".previous and .next goals" do
    let!(:team) { create(:team) }
    let!(:old_kudos_meter)   { create :kudos_meter, name: "closed kudos_meter", team: team  }
    let!(:current_kudos_meter)   { create :kudos_meter, name: "current kudos_meter", team: team  }
    let!(:old_goal)   { create :goal, :achieved, achieved_on: 100.days.ago, amount: 600, kudos_meter: old_kudos_meter }
    let!(:goal_one)   { create :goal, :achieved, achieved_on: 60.days.ago, amount: 100, kudos_meter: current_kudos_meter }
    let!(:goal_two)   { create :goal, :achieved, achieved_on: 30.day.ago, amount: 200,  kudos_meter: current_kudos_meter }
    let!(:goal_three) { create :goal, amount: 300,  kudos_meter: current_kudos_meter }
    let!(:goal_four)  { create :goal, amount: 400,  kudos_meter: current_kudos_meter }

    it "finds the previous goal" do
      expect(Goal.previous(team)).to eq(goal_two)
    end

    it "finds the next goal" do
      expect(Goal.next(team)).to eq(goal_three)
    end
  end

  context "#achieve" do
    let(:goal) { create :goal }

    it "marks goals as achieved" do
      expect {
        goal.achieve!
      }.to change { goal.achieved? }.from(false).to(true)
    end
  end
end
