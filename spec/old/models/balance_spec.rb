# frozen_string_literal: true

require "rails_helper"

describe Balance, type: :model do
  let(:team) { create :team }
  let(:user) { create :user }
  let(:user_2) { create :user }
  let(:balance) { Balance.current(team) }
  let(:balance_2) { create :balance, current: false, team_id: team.id }
  let(:balance_3) { create :balance, :current, created_at: "2016-12-31 23:00:00", team_id: team.id }
  let!(:post) { create(:post, sender: user, receivers: [user_2], balance: balance, created_at: "2016-12-31 22:00:00", team_id: team) }
  let!(:post_2) { create(:post, sender: user, receivers: [user_2], balance: balance, created_at: "2016-12-31 23:00:00", team_id: team) }

  before do
    team.add_member user
    Timecop.freeze(Time.new(2017, 01, 01))
  end

  describe "#time_left" do
    it "calculates the days left until the end of the year" do
      Balance.time_left

      expect(Balance.time_left).to eq("364 days left")
    end
  end

  describe "#amount" do
    it "calculates the amount of the balance" do
      expect(balance.amount).to eq(Post.all.sum(:amount))
    end
  end

  describe "#last_post" do
    it "finds the last post" do
      expect(balance.last_post).to eq(post_2)
    end
  end

  describe "#current" do
    it "find the first created and current balance" do
      expect(Balance.current(team.id)).to eq(balance)
    end
  end
end
