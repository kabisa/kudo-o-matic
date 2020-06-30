RSpec.describe KudosMeter, type: :model do
  let(:team) { create(:team) }
  let(:team_with_slack) {create(:team, :with_slack)}
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  before :each do
    team.add_member(user)
    team.add_member(other_user)

    team_with_slack.add_member(user)
    team_with_slack.add_member(other_user)
  end

  describe 'create post' do
    it 'creates a post' do
      expect {
        PostCreator.create_post('Some message', 5, user, [other_user], team)
      }.to change { Post.count }.by(1)
    end

    it 'sends the announcement email' do
      PostCreator.create_post('Some message', 5, user, [other_user], team)

      expect(ActiveJob::Base.queue_adapter.enqueued_jobs.last[:args]).to include('PostMailer', 'post_email', 'deliver_now')
    end

    it 'checks whether the goal has been reached' do
      expect(GoalReacher).to receive(:check!)
      PostCreator.create_post('Some message', 5, user, [other_user], team)
    end

    it 'sends the slack announcement if the team is connected to Slack' do
      expect(SlackService).to receive(:send_post_announcement)
      PostCreator.create_post('Some message', 5, user, [other_user], team_with_slack)
    end

    it 'doesnt send the slack announcement if the team is not connected to Slack' do
      expect(SlackService).to_not receive(:send_post_announcement)
      PostCreator.create_post('Some message', 5, user, [other_user], team)
    end

    it 'doesnt send the slack announcement if the option is set to false' do
      expect(SlackService).to_not receive(:send_post_announcement)
      PostCreator.create_post('Some message', 5, user, [other_user], team_with_slack, false)
    end
  end
end
