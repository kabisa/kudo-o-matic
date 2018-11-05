# frozen_string_literal: true

require "rails_helper"

describe BalanceDecorator do
  let!(:prev_goal) { create :goal, amount: 500 }
  let!(:next_goal) { create :goal, amount: 1000 }
  let(:team) { create :team }
  let(:user) { create(:user, avatar_url: "/kabisa_lizard.png") }
  let(:balance) { create :balance, current: :current, team_id: team.id }
  let!(:post) { create(:post, sender: user, receivers: [user], amount: 100, team_id: team.id, balance: balance) }
  let!(:post_2) { create(:post, sender: user, receivers: [user],  amount: 100, team_id: team.id, balance: balance) }
  let!(:post_3) { create(:post, sender: user, receivers: [user],  amount: 500, team_id: team.id, balance: balance) }

  subject { balance.decorate }

  before do
    team.add_member(user)
  end

  it "renders amount in Kudos" do
    @post_amount = Post.where(balance: Balance.current(team.id)).sum(:amount)
    expect(@post_amount).to eq(700)
  end
end
