# frozen_string_literal: true

require "rails_helper"
require "rss"

describe "/feed", type: :request do
  let!(:team) { create :team, name: "kabisa", slug: "kabisa" }
  let!(:team_2) { create :team, name: "other team", slug: "other-team" }

  context "no posts" do
    it "produces an empty feed" do
      expect(parse_feed).to be_empty
    end
  end

  context "given many posts" do
    let(:user) { create(:user) }
    let(:user_2) { create(:user) }
    let(:balance) { create :balance, :current }
    let!(:posts) { create_list(:post, 26, sender: user, receivers: [user, user_2], balance: balance, created_at: Date.yesterday.to_time, team: team) }

    it "includes last 25 entries" do
      entries = parse_feed
      expect(extract_ids(entries)).to eq(posts.last(25).map(&:id))
    end

    it "includes basic info in entries" do
      entry = parse_feed[0]
      post = posts.second

      expect(entry.title.content).to include("New post")
      expect(entry.summary.content).to eq("#{post.sender.name} awarded #{post.receiver_name_feed} #{post.amount} ₭ for #{post.message}")
    end

    it "overrides updated timestamps so updates dont (re)appear in the feed" do
      posts.first.touch
      entries = parse_feed

      expect(entries.first.updated.content).to eq(posts.first.created_at)
    end

    it "renders 404 with wrong token" do
      get "/#{team.slug}/feed/faketoken"

      expect(response).to have_http_status(404)
    end

    it "renders 404 when visiting other teams feed with own token" do
      get "/#{team_2.slug}/feed/#{team.rss_token}"

      expect(response).to have_http_status(404)
    end
  end

  def extract_ids(entries)
    entries.map { |e| e.id.content.split("Post/")[1].to_i }
  end

  def parse_feed
    get "/#{team.slug}/feed/#{team.rss_token}"
    RSS::Parser.parse(response.body).entries
  end
end
