# frozen_string_literal: true

RSpec.describe Mutations::Post::CreatePost do
  set_graphql_type

  let!(:user) { create(:user) }
  let!(:users) { create_list(:user, 5) }
  let!(:team) { create(:team) }
  let(:kudos_meter) { team.active_kudos_meter }
  let(:goals) { kudos_meter.goals }

  before do
    users.each { |user| team.add_member(user) }
  end

  let(:variables) do
    {
      message: 'the message',
      amount: 5,
      receiver_ids: [users.fourth.id, users.fifth.id],
      null_receivers: ['Harry'],
      team_id: team.id,
      images: []
    }
  end

  let(:result) do
    res = execute_query
    res
  end

  let(:mutation_string) do
    %( mutation { createPost(
      message: "#{variables[:message]}"
      amount: #{variables[:amount]}
      receiverIds: #{variables[:receiver_ids]}
      nullReceivers: #{variables[:null_receivers]}
      teamId: #{variables[:team_id]}
      images: []
    ) { post { id } } } )
  end

  def execute_query
    KudoOMaticSchema.execute(
        mutation_string,
        context: context,
        variables: variables
    )
  end

  context 'authenticated' do
    let(:context) { { current_user: user } }

    describe 'user is admin' do
      before do
        user.update(admin: true)
      end

      it 'can create a post and sends out emails to the receivers' do
        expect { result }.to change { Post.count }.by(1)
      end

      it 'returns no errors' do
        expect(result['errors']).to be_nil
      end
    end

    describe 'user is team member' do
      before do
        team.add_member(user)
      end

      it 'can create a post and sends out emails to the receivers' do
        expect { result }.to change { Post.count }.by(1)
      end

      it 'does not duplicate virtual users' do
        execute_query
        execute_query

        expect(User.where(name: 'Harry', virtual_user: true).size).to be(1)
      end

      it 'returns no errors' do
        expect(result['errors']).to be_nil
      end
    end

    describe 'user is not a team member' do
      it 'can\'t create a post' do
        expect { result }.to_not change {
          Post.count
          ActiveJob::Base.queue_adapter.enqueued_jobs.size
        }

        expect(result['data']['createPost']).to be_nil
      end

      it 'returns a not authorized error for Mutation.createPost' do
        expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.createPost')
      end
    end
  end

  context 'not authenticated' do
    let(:context) { { current_user: nil } }

    it 'can\'t create a post' do
      expect(result['data']['createPost']).to be_nil
    end

    it 'returns a not authorized error for Mutation.createPost' do
      expect(result['errors'].first['message']).to eq('Not authorized to access Mutation.createPost')
    end
  end
end