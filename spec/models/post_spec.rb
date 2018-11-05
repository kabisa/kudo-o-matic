# frozen_string_literal: true

RSpec.describe Post, type: :model do
  let(:user) { create(:user) }
  let(:user_2) { create(:user) }

  it "should have a valid factory" do
    expect(build(:post, sender: user, receivers: [user_2])).to be_valid
  end

  let!(:post) { create(:post, sender: user, receivers: [user_2]) }

  describe "model destroy dependencies" do
    it "should destroy dependent PostReceivers" do
      expect { post.destroy }.to change { PostReceiver.count }
    end
  end

  describe "model validations" do
    # ensure that the sender field is never empty
    it { expect(post).to validate_presence_of(:sender) }
    # ensure that the receivers field is never empty
    it { expect(post).to validate_presence_of(:receivers) }
    # ensure that the message field is never empty
    it { expect(post).to validate_presence_of(:message) }
    # ensure that the message field is between a certain length
    it { expect(post).to validate_length_of(:message) }
    # ensure that the amount field is never empty
    it { expect(post).to validate_presence_of(:amount) }
    # ensure that the number of amount is between a specific numericality
    it { expect(post).to validate_numericality_of(:amount) }
  end

  describe "model associations" do
    # ensure that a post belongs to balance
    it { expect(post).to belong_to(:balance) }
    # ensure that a post belongs to team
    it { expect(post).to belong_to(:team) }
    # ensure that a post belongs to activity
    it { expect(post).to belong_to(:activity) }
    # ensure that a user belongs to sent_posts
    it { expect(post).to belong_to(:sender) }
    # ensure that a post has many post_receivers
    it { expect(post).to have_many(:post_receivers).dependent(:destroy) }
    # ensure that a post has many received_posts through post_receivers
    it { expect(post).to have_many(:receivers).through(:post_receivers) }
    # ensure that a post has many votes
    it { expect(post).to have_many(:votes).with_foreign_key("votable_id") }
  end

  describe "model delegations" do
    # ensure that sender name is delegated to sender as name with prefix true
    it { should delegate_method(:name).to(:sender).with_prefix(true) }
  end
end
