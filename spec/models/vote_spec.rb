RSpec.describe Vote, type: :model do
  let!(:team) { create(:team) }
  let(:kudos_meter) { team.active_kudos_meter }
  let(:goals) { team.current_goals }
  let(:users) { create_list(:user, 2) }
  let(:post) { create(:post, sender: users.first, receivers: [users.second], team: team, kudos_meter: kudos_meter) }
  let!(:vote) { create(:vote, votable_id: post.id, voter_id: users.first.id) }

  describe "model associations" do
    # ensure that a vote belongs to user_voter
    it { expect(vote).to belong_to(:user_voter).with_foreign_key('voter_id') }
    # ensure that a vote belongs to post_votable
    it { expect(vote).to belong_to(:post_votable).with_foreign_key('votable_id') }
  end
end