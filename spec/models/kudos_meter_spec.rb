# frozen_string_literal: true

RSpec.describe KudosMeter, type: :model do
  let(:users) { create_list(:user, 5) }
  let(:team) { create(:team) }
  let!(:kudos_meter) { team.active_kudos_meter }
  let!(:goal) { team.current_goals }

  before do
    users.each { |user| team.add_member(user) }
  end

  let!(:post) { create(:post, sender: users.first, receivers: [users.second], kudos_meter: kudos_meter, team: team) }
  let!(:vote) { create(:vote, voter_id: users.first.id, voter_type: "User", votable_id: post.id, votable_type: "Post") }
  let!(:vote_2) { create(:vote, voter_id: users.second.id, voter_type: "User", votable_id: post.id, votable_type: "Post") }
  let!(:vote_3) { create(:vote, voter_id: users.third.id, voter_type: "User", votable_id: post.id, votable_type: "Post") }

  it "should have a valid factory" do
    expect(build(:kudos_meter)).to be_valid
  end

  describe "model destroy dependencies" do
    it "should destroy dependent Posts" do
      expect { kudos_meter.destroy }.to change { Post.count }
    end

    it "should destroy dependent Goals" do
      expect { kudos_meter.destroy }.to change { Goal.count }
    end
  end

  describe "model validations" do
    it { expect(kudos_meter).to validate_presence_of(:name) }
  end

  describe "model associations" do
    it { is_expected.to belong_to(:team) }
    it { is_expected.to have_many(:posts).dependent(:destroy) }
    it { is_expected.to have_many(:goals).dependent(:destroy) }
  end

  describe '.likes(kudos_meter)' do
    it 'returns the likes that belong to the kudos meter' do
      expect(KudosMeter.likes(kudos_meter)).to eq(3)
    end
  end

  describe '#amount' do
    it 'returns the total amount of kudos from posts and likes' do
      expect(kudos_meter.amount).to eq(post.kudos_amount)
    end
  end
end
