RSpec.describe Vote, type: :model do
  describe "model associations" do
    it { is_expected.to belong_to(:user_voter).with_foreign_key('voter_id') }
    it { is_expected.to belong_to(:post_votable).with_foreign_key('votable_id') }
  end
end