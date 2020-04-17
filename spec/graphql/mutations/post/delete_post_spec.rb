# frozen_string_literal: true

RSpec.describe Mutations::Post::DeletePost do
  set_graphql_type

  let!(:user) { create(:user) }
  let!(:users) { create_list(:user, 5) }
  let!(:team) { create(:team) }
  let(:kudos_meter) { team.active_kudos_meter }
  let(:goals) { kudos_meter.goals }

  before do
    users.each { |user| team.add_member(user) }
  end

  let(:post) { create(:post, sender: user, receivers: [users.second], team: team, kudos_meter: kudos_meter) }
  let(:post_2) { create(:post, sender: users.first, receivers: [users.second, users.third], team: team, kudos_meter: kudos_meter) }

  let(:result) do
    res = KudoOMaticSchema.execute(
      mutation_string,
      context: context,
      variables: variables
    )
    res
  end

  let(:mutation_string) do
    %( mutation { deletePost(
      id: "#{variables[:id]}"
    ) { postId } } )
  end

  context 'authenticated' do
    let(:context) { { current_user: user } }

    describe 'user is admin' do
      before do
        user.update(admin: true)
      end

      let(:variables) { { id: post_2.id } }

      it 'can delete a post' do
        expect(result['data']['deletePost']['postId'].to_i).to eq(post_2.id)
      end

      it 'can delete a post that is older than 15 minutes' do
        post_2.update(created_at: 1.day.ago)
        expect(result['data']['deletePost']['postId'].to_i).to eq(post_2.id)
      end

      it 'returns no errors' do
        expect(result['errors']).to be_nil
      end
    end

    describe 'user is team admin' do
      before do
        team.add_member(user, 'admin')
      end

      let(:variables) { { id: post_2.id } }

      it 'can delete a post' do
        expect(result['data']['deletePost']['postId'].to_i).to eq(post_2.id)
      end

      it 'can delete a post that is older than 15 minutes' do
        post_2.update(created_at: 1.day.ago)
        expect(result['data']['deletePost']['postId'].to_i).to eq(post_2.id)
      end

      it 'returns no errors' do
        expect(result['errors']).to be_nil
      end
    end

    describe 'user is team member' do
      before do
        team.add_member(user)
      end

      let(:variables) { { id: post.id } }

      it 'can delete it\'s own post' do
        expect(result['data']['deletePost']['postId'].to_i).to eq(post.id)
      end

      it 'can\'t delete a post that is older than 15 minutes' do
        post.update(created_at: 1.day.ago)
        expect(result['data']['deletePost']).to be_nil
      end

      it 'returns a not authorized error for Mutation.deletePost' do
        post.update(created_at: 1.day.ago)
        expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.deletePost')
      end
    end

    describe 'user is a team member' do
      before do
        team.add_member(user)
      end

      let(:variables) { { id: post_2.id } }

      it 'can\'t delete a post from someone else' do
        expect(result['data']['deletePost']).to be_nil
      end

      it 'returns a not authorized error for Mutation.deletePost' do
        expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.deletePost')
      end
    end

    describe 'user is not a team member' do
      let(:variables) { { id: post_2.id } }

      it 'can\'t delete a post' do
        expect(result['data']['deletePost']).to be_nil
      end

      it 'returns a not authorized error for Mutation.deletePost' do
        expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.deletePost')
      end
    end
  end

  context 'not authenticated' do
    let(:context) { { current_user: nil } }
    let(:variables) { { id: post.id } }

    it 'can\'t delete a post' do
      expect(result['data']['deletePost']).to be_nil
    end

    it 'returns a not authorized error for Mutation.deletePost' do
      expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.deletePost')
    end
  end
end