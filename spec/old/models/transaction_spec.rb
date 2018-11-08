# frozen_string_literal: true

require "rails_helper"

describe Post do
  before(:all) do
    ActiveRecord::Base.skip_callbacks = true
  end

  after(:all) do
    ActiveRecord::Base.skip_callbacks = false
  end

  context "given no receiver" do
    let(:user) { create(:user) }
    let(:user_2) { create(:user) }
    let(:post) { create(:post, sender: user, receivers: [user_2]) }

    # Skip because receiver presence is now validated
    xit "extracts the receiver name from the activity", callbacks: false do
      expect(post.receivers).to eq([user_2])
    end

    xit "returns the standard no-receiver image", callbacks: false do
      expect(post.receiver_image).to eq("/kabisa_lizard.png")
    end
  end

  context "given a receiver" do
    let(:user) { create(:user, avatar_url: "/kabisa_lizard.png") }
    let(:team) { create(:team) }
    let(:kudos_meter) { team.active_kudos_meter }
    let(:post) { create(:post, sender: user, receivers: [user], team: team, kudos_meter: kudos_meter) }

    it "returns the receiver name", callbacks: false do
      expect(post.receivers).to eq([user])
    end

    it "returns the message", callbacks: false do
      expect(post.message).to eq(post.message)
    end

    it "returns the receiver image", callbacks: false do
      expect(post.receiver_image).to eq(user.avatar_url)
    end
  end

  context " filter posts" do
    let(:team) { create :team }
    let(:user) { create :user }
    let(:user_2) { create :user }
    let(:user_3) { create :user }
    let(:kudos_meter) { create :kudos_meter, team: team }
    let!(:posts) { create_list(:post, 4, sender: user_2, receivers: [user], kudos_meter: kudos_meter, team: team) }

    before do
      team.add_member(user)
      team.add_member(user_2)
      team.add_member(user_3)
    end

    it "Displays all my posts from the current kudos_meter" do
      posts = Post.all_for_user_in_team(user_2, team)

      expect(posts.count).to eq(4)
    end

    it "Displays my send posts from the current kudos_meter" do
      posts = Post.send_by_user(user_2, team)

      expect(posts.count).to eq(4)
    end

    it "Displays my received posts from the current kudos_meter" do
      posts = Post.received_by_user(user, team)

      expect(posts.count).to eq(4)
    end

    it "Displays no posts" do
      posts = Post.received_by_user(user_3, team.id)

      expect(posts.count).to eq(0)
    end
  end
end
