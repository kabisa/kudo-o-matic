# frozen_string_literal: true

require "rails_helper"

RSpec.describe GoalReacher, type: :model do
  let!(:team) { create(:team) }
  let!(:user) { create(:user) }
  let!(:user_2) { create(:user)  }
  let(:user_goal) { User.create name: "Kabisa" }
  let(:balance) { Balance.current(team.id) }
  let!(:goal) { team.current_goals.first }
  let!(:goal_2) { team.current_goals.second }

  before do
    team.add_member user
    team.add_member user_2
  end

  context "The next goal is achieved" do
    let!(:post) {
      create :post, sender: user, receivers: [user_2], balance: balance, amount: 499
    }
    let!(:post_2) {
      create :post, sender: user, receivers: [user], balance: balance
    }

    it "marks the next goal as achieved" do
      GoalReacher.check!(team.id)
      expect(Goal.previous(team.id)).to eq(goal)
    end

    xit "sends an email" do
      GoalMailer.goal_email(user, team, goal).deliver_now
      expect(ActionMailer::Base.deliveries.count).to be(1)
    end

    # Skipped because of unused function Post.goal_reached_post
    xit "creates a post for the reached goal" do
      GoalReacher.check!(team.id)
      expect(Post.last.activity.name).to eq("reaching the goal #{Goal.previous(team.id).name} :boom:, here are some ₭udos to boost your hunt for the next goal")
    end
  end
end
