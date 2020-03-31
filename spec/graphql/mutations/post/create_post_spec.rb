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
      team_id: team.id
    }
  end

  let(:result) do
    res = KudoOMaticSchema.execute(
      mutation_string,
      context: context,
      variables: variables
    )
    res
  end

  let(:mutation_string) do
    %( mutation { createPost(
      message: "#{variables[:message]}"
      amount: #{variables[:amount]}
      receiverIds: #{variables[:receiver_ids]}
      teamId: #{variables[:team_id]}
    ) { post { id } } } )
  end

  context 'authenticated' do
    let(:context) { { current_user: user } }

    describe 'user is admin' do
      before do
        user.update(admin: true)
      end

      it 'can create a post and sends out emails to the receivers' do
        expect { result }.to change { Post.count }.by(1)
          .and change { ActiveJob::Base.queue_adapter.enqueued_jobs.size }.by(2)

        expect(ActiveJob::Base.queue_adapter.enqueued_jobs.last[:args]).to include('PostMailer', 'post_email', 'deliver_now')
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
          .and change { ActiveJob::Base.queue_adapter.enqueued_jobs.size }.by(2)

        expect(ActiveJob::Base.queue_adapter.enqueued_jobs.last[:args]).to include('PostMailer', 'post_email', 'deliver_now')
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