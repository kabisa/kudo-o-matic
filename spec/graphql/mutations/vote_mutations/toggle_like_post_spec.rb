# frozen_string_literal: true

RSpec.describe Mutations::VoteMutation, ":toggleLikePost" do
  let!(:team) { create(:team) }
  let(:kudos_meter) { team.active_kudos_meter }
  let(:goals) { team.current_goals }
  let!(:users) { create_list(:user, 2) }
  let!(:post) { create(:post, sender: users.first, receivers: [users.second], team: team, kudos_meter: kudos_meter) }

  context "user is authenticated" do
    describe 'it likes a post' do
      it "should add one like to a post" do
        args = { post_id: post.id }
        ctx = { current_user: users.first }

        expect do
          subject.fields["toggleLikePost"].resolve(nil, args, ctx)
        end.to change { post.votes.count }.by(1)
      end
    end

    describe 'it unlikes a post' do
      it "should delete one like from a post" do
        post.liked_by users.first
        args = { post_id: post.id }
        ctx = { current_user: users.first }

        expect do
          subject.fields["toggleLikePost"].resolve(nil, args, ctx)
        end.to change { post.votes.count }.by(-1)
      end
    end
  end

  context 'user is not authenticated' do
    describe 'it likes a post' do
      it "should require authentication before liking" do
        args = { post_id: post.id }
        ctx = { current_user: nil }

        expect do
          subject.fields["toggleLikePost"].resolve(nil, args, ctx)
        end.to raise_error(GraphQL::ExecutionError, "Authentication required")
      end
    end

    describe 'it unlikes a post' do
      it "should require authentication before liking" do
        post.liked_by users.first
        args = { post_id: post.id }
        ctx = { current_user: nil }

        expect do
          subject.fields["toggleLikePost"].resolve(nil, args, ctx)
        end.to raise_error(GraphQL::ExecutionError, "Authentication required")
      end
    end
  end
end