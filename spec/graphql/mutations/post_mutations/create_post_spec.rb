# frozen_string_literal: true

RSpec.describe Mutations::PostMutation, ":createPost" do
  let(:users) { create_list(:user, 2) }
  let!(:team) { create(:team) }
  let(:kudos_meter) { team.active_kudos_meter }

  context "create valid post" do
    it "creates a new post" do
      args = {
          message: Faker::Lorem.sentence(3),
          amount: rand(0..500),
          receiver_ids: [users.last.id],
          team_id: team.id,
          kudos_meter_id: kudos_meter.id
      }
      ctx = { current_user: users.first }

      expect {
        subject.fields["createPost"].resolve(nil, args, ctx)
      }.to change { Post.count }.by(1)
    end
  end

  context "create invalid post" do
    let(:args) { {
        message: "one",
        amount: rand(0..500),
        receiver_ids: [],
        team_id: team.id,
        kudos_meter_id: kudos_meter.id
    } }

    it "raises an ExecutionError if post is not saved" do
      ctx = { current_user: users.first }
      expect do
        subject.fields["createPost"].resolve(nil, args, ctx)
      end.to raise_error(GraphQL::ExecutionError)
    end
  end

  context "unauthenticated user" do
    it "raises an ExecutionError if user is not authenticated" do
      ctx = { current_user: nil }
      expect do
        subject.fields["createPost"].resolve(nil, nil, ctx)
      end.to raise_error(GraphQL::ExecutionError, "Authentication required")
    end
  end
end
