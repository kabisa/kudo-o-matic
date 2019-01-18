# frozen_string_literal: true

require "rails_helper"

describe KudosMeterDecorator do
  let!(:prev_goal) { create :goal, amount: 500 }
  let!(:next_goal) { create :goal, amount: 1000 }
  let(:team) { create :team }
  let(:user) { create(:user, avatar_url: "/kabisa_lizard.png") }

  before do
    team.add_member(user)
  end

  let(:kudos_meter) { team.active_kudos_meter }
  let!(:post) { create(:post, sender: user, receivers: [user], amount: 100, team_id: team.id, kudos_meter: kudos_meter) }
  let!(:post_2) { create(:post, sender: user, receivers: [user],  amount: 100, team_id: team.id, kudos_meter: kudos_meter) }
  let!(:post_3) { create(:post, sender: user, receivers: [user],  amount: 500, team_id: team.id, kudos_meter: kudos_meter) }

  subject { kudos_meter.decorate }

  before do
    team.add_member(user)
  end

  it "renders amount in Kudos" do
    @post_amount = Post.where(kudos_meter: team.active_kudos_meter).sum(:amount)
    expect(@post_amount).to eq(700)
  end
end
