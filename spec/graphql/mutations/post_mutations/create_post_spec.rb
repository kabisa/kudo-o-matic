# frozen_string_literal: true

RSpec.describe Mutations::PostMutation, ":createPost" do
  let!(:users) { create_list(:user, 2) }
  let!(:team) { create(:team) }
  let(:kudos_meter) { team.active_kudos_meter }
  let(:goals) { kudos_meter.goals }
  let!(:team_member) { create(:team_member) }

  context "create valid post" do
    let(:ctx) { { current_user: users.first } }

    it "creates a new post with existing users" do
      args = {
          message: 'message',
          amount: 50,
          receiver_ids: [users.last.id],
          team_id: team.id,
          kudos_meter_id: kudos_meter.id
      }

      expect do
        subject.fields["createPost"].resolve(nil, args, ctx)
      end.to change { Post.count }.by(1)
     .and change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it "creates a new post with non-existing users" do
      args = {
          message: 'message',
          amount: 50,
          null_receivers: ["Harry"],
          team_id: team.id,
          kudos_meter_id: kudos_meter.id
      }

      expect do
        subject.fields["createPost"].resolve(nil, args, ctx)
      end.to change { Post.count }.by(1)
      .and change { ActionMailer::Base.deliveries.count }.by(0)
      .and change { User.count }.by(1)
    end

    it "creates a new post with existing and non-existing users" do
      args = {
          message: 'message',
          amount: 50,
          receiver_ids: [users.last.id],
          null_receivers: ["Harry"],
          team_id: team.id,
          kudos_meter_id: kudos_meter.id
      }

      expect do
        subject.fields["createPost"].resolve(nil, args, ctx)
      end.to change { Post.count }.by(1)
      .and change { ActionMailer::Base.deliveries.count }.by(1)
      .and change { User.count }.by(1)
    end

    it 'checks and sends an email if a goal is reached' do
      args = {
        message: Faker::Lorem.sentence(3),
        amount: 500,
        receiver_ids: [users.last.id],
        team_id: team.id,
        kudos_meter_id: kudos_meter.id
      }

      expect do
        subject.fields["createPost"].resolve(nil, args, ctx)
      end.to change { ActionMailer::Base.deliveries.count }.by(2)
    end
  end

  context "create invalid post" do
    let(:args) {
      {
        message: "one",
        amount: rand(0..500),
        receiver_ids: [],
        team_id: team.id,
        kudos_meter_id: kudos_meter.id
      }
    }

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
