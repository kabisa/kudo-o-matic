# frozen_string_literal: true

RSpec.describe Mutations::PostMutation, ":createPost" do
  let!(:users) { create_list(:user, 3) }
  let!(:team) { create(:team) }
  let(:kudos_meter) { team.active_kudos_meter }
  let(:goals) { kudos_meter.goals }

  context "authenticated user" do
    let!(:post) { create(:post, sender: users.first, receivers: [users.second], team: team, kudos_meter: kudos_meter) }
    let!(:old_post) { create(:post, sender: users.first, receivers: [users.second], team: team, kudos_meter: kudos_meter, created_at: DateTime.now - 16.minutes) }

    describe 'current user is sender' do
      let(:ctx) { { current_user: users.first } }

      it "deletes the post" do
        args = { id: post.id }

        expect do
          subject.fields["deletePost"].resolve(nil, args, ctx)
        end.to change { Post.count }.by(-1)
      end

      it 'can\'t delete the post if post is created more than 15 minutes ago' do
        args = { id: old_post.id }

        expect do
          subject.fields["deletePost"].resolve(nil, args, ctx)
        end.to raise_error(GraphQL::ExecutionError, "Permissioned denied: You are not authorized to perform this action")
      end
    end

    describe 'current user is team admin' do
      before do
        team.add_member(users.second, 'admin')
      end
      let(:ctx) { { current_user: users.second } }

      it "deletes the post" do
        args = { id: post.id }

        expect do
          subject.fields["deletePost"].resolve(nil, args, ctx)
        end.to change { Post.count }.by(-1)
      end

      it 'can delete the post if post is created more than 15 minutes ago' do
        args = { id: old_post.id }

        expect do
          subject.fields["deletePost"].resolve(nil, args, ctx)
        end.to change { Post.count }.by(-1)
      end
    end

    describe 'current user is app admin' do
      before do
        users.third.update(admin: true)
      end
      let(:ctx) { { current_user: users.third } }

      it "deletes the post" do
        args = { id: post.id }

        expect do
          subject.fields["deletePost"].resolve(nil, args, ctx)
        end.to change { Post.count }.by(-1)
      end

      it 'can delete the post if post is created more than 15 minutes ago' do
        args = { id: old_post.id }

        expect do
          subject.fields["deletePost"].resolve(nil, args, ctx)
        end.to change { Post.count }.by(-1)
      end
    end

    describe 'current user is not the sender' do
      let(:ctx) { { current_user: users.third } }

      it "can\'t delete the post" do
        args = { id: post.id }

        expect do
          subject.fields["deletePost"].resolve(nil, args, ctx)
        end.to raise_error(GraphQL::ExecutionError, "Permissioned denied: You are not authorized to perform this action")
      end
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
