# frozen_string_literal: true

RSpec.describe Mutations::Vote::ToggleLikePost do
  set_graphql_type

  before do
    users.each { |user| team.add_member(user) }
  end

  let(:user) { create(:user) }
  let(:users) { create_list(:user, 5) }
  let!(:team) { create(:team) }
  let(:kudos_meter) { team.active_kudos_meter }
  let(:post) { create(:post, sender: users.first, receivers: [users.second], team: team, kudos_meter: kudos_meter) }

  let(:context) { { current_user: user } }
  let(:variables) { { post_id: post.id } }
  let(:result) do
    res = KudoOMaticSchema.execute(
      mutation_string,
      context: context,
      variables: variables
    )
    res
  end

  let(:mutation_string) do
    %( mutation { toggleLikePost(
      postId: "#{variables[:post_id]}"
    ) { post { id } } } )
  end

  context 'authenticated' do
    describe 'user is admin' do
      before do
        user.update(admin: true)
      end

      it 'can toggle like a post' do
        expect { result }.to change { post.votes.count }.by(1)
        expect(result['data']['toggleLikePost']['post']['id'].to_i).to eq(post.id)
      end

      it 'returns no errors' do
        expect(result['errors']).to be_nil
      end
    end

    describe 'user is team member' do
      before do
        team.add_member(user)
      end

      it 'can toggle like a post' do
        expect { result }.to change { post.votes.count }.by(1)
        expect(result['data']['toggleLikePost']['post']['id'].to_i).to eq(post.id)
      end

      it 'returns no errors' do
        expect(result['errors']).to be_nil
      end
    end

    describe 'user is not a team member' do
      it 'can\'t toggle like a post' do
        expect { result }.to_not change { post.votes.count }
        expect(result['data']['toggleLikePost']).to be_nil
      end

      it 'returns a not authorized error for Mutation.toggleLikePost' do
        expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.toggleLikePost')
      end
    end
  end

  context 'not authenticated' do
    let(:context) { { current_user: nil } }

    it 'can\'t toggle like a post' do
      expect { result }.to_not change { post.votes.count }
      expect(result['data']['toggleLikePost']).to be_nil
    end

    it 'returns a not authorized error for Mutation.toggleLikePost' do
      expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.toggleLikePost')
    end
  end
end