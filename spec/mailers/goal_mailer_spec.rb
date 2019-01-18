RSpec.describe GoalMailer, type: :mailer do
  context 'new goal reached' do
    let(:team) { create :team }
    let(:kudos_meter) { team.active_kudos_meter }
    let!(:goals) { kudos_meter.goals }
    let!(:reached_goal) { goals.first.achieve! }
    let(:user) { create(:user, name: 'John Doe', email: 'johndoe@example.com') }
    let(:mail) { described_class.goal_email(user, team, goals.first) }

    before do
      team.add_member(user)
    end

    it 'renders the subject' do
      expect(mail.subject).to eq("Goal '#{goals.first.name}' is reached! \u{1f389}")
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq([user.email])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq(['example@mail.com'])
    end

    it 'assigns the previous goal' do
      expect(mail.body.encoded).to match(goals.first.name)
    end

    it 'sends the email' do
      expect { mail.deliver_now }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'logo attachment is added' do
      expect(mail.attachments.count).to eq(1)
    end
  end
end