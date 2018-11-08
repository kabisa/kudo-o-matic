# frozen_string_literal: true

require "rails_helper"

describe KudosMeter, type: :model do
  let(:team) { create :team }
  let(:kudos_meter) { create(:kudos_meter, team: team) }
  let(:user) { create :user }
  let(:user_2) { create :user }
  let!(:post) { create(:post, sender: user, receivers: [user_2], kudos_meter: kudos_meter, created_at: "2016-12-31 22:00:00", team: team) }
  let!(:post_2) { create(:post, sender: user, receivers: [user_2], kudos_meter: kudos_meter, created_at: "2016-12-31 23:00:00", team: team) }

  before do
    team.add_member user
    Timecop.freeze(Time.new(2017, 01, 01))
  end

  describe "#time_left" do
    it "calculates the days left until the end of the year" do
      KudosMeter.time_left

      expect(KudosMeter.time_left).to eq("364 days left")
    end
  end

  describe "#amount" do
    it "calculates the amount of the kudos_meter" do
      expect(kudos_meter.amount).to eq(Post.all.sum(:amount))
    end
  end

  describe "#last_post" do
    it "finds the last post" do
      expect(kudos_meter.last_post).to eq(post_2)
    end
  end
end
