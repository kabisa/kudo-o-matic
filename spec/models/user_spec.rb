# frozen_string_literal: true

RSpec.describe User, type: :model do
  it "should have a valid factory" do
    expect(build(:user)).to be_valid
  end

  it "should have valid factory aliases" do
    expect(build(:sender)).to be_valid
    expect(build(:receiver)).to be_valid
  end

  let(:user) { create(:user) }
  let(:user_2) { create(:user) }
  let!(:post) { create(:post, sender: user, receivers: [user_2]) }
  let!(:post_2) { create(:post, sender: user_2, receivers: [user]) }

  describe "model destroy dependencies" do
    it "should destroy dependent SentPosts" do
      # ensure that dependent SentPosts are deleted
      expect { user.destroy }.to change { PostReceiver.count }
    end

    it "should destroy dependent ReceivedPosts" do
      # ensure that dependent ReceivedPosts are deleted
      expect { user.destroy }.to change { PostReceiver.count }
    end
  end

  describe "model validations" do
    # ensure that the name field is never empty
    it { expect(user).to validate_presence_of(:name) }
    # ensure that the email field is never empty
    it { expect(user).to validate_presence_of(:email) }
    # ensure that the email field is unique
    it { expect(user).to validate_uniqueness_of(:email).ignoring_case_sensitivity }
  end

  describe "model associations" do
    # ensure that a user has many sent_posts with foreign key sender_id
    it { expect(user).to have_many(:sent_posts).dependent(:destroy).with_foreign_key("sender_id") }
    # ensure that a user has many post_receivers
    it { expect(user).to have_many(:post_receivers).dependent(:destroy) }
    # ensure that a user has many received_posts through post_receivers
    it { expect(user).to have_many(:received_posts).through(:post_receivers) }
    # ensure that a user has many memberships with foreign key user_id
    it { expect(user).to have_many(:memberships).with_foreign_key("user_id") }
    # ensure that a user has many teams through memberships
    it { expect(user).to have_many(:teams).through(:memberships) }
    # ensure that a user has many votes with foreign key voter_id
    it { expect(user).to have_many(:votes).with_foreign_key("voter_id") }
    # ensure that a user has many exports with foreign key user_id
    it { expect(user).to have_many(:exports).with_foreign_key("user_id") }
    # ensure that a user has many fcm_tokens
    it { expect(user).to have_many(:fcm_tokens) }
  end
end
