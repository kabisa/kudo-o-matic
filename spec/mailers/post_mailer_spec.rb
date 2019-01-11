RSpec.describe PostMailer, type: :mailer do
  context 'new post' do
    let(:team) { create(:team) }
    let(:kudos_meter) { create(:kudos_meter, team: team) }
    let(:user) { (create :user, name: 'John Doe', email: 'johndoe@example.com') }

    before do
      team.add_member(user)
    end

    let!(:post) { create(:post, sender: user, receivers: [user], team: team, kudos_meter: kudos_meter) }
    let(:mail) { described_class.post_email(user, post) }

    it 'renders the subject' do
      expect(mail.subject).to eq("You just received #{post.amount} ₭ from John Doe!")
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq([user.email])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq(['example@mail.com'])
    end

    it 'assigns @user' do
      expect(mail.body.encoded).to match(user.first_name)
    end

    it 'assigns @post' do
      expect(mail.body.encoded).to match(post.sender.name)
      expect(mail.body.encoded).to match(post.receivers.first.name)
      expect(mail.body.encoded).to match(post.amount.to_s)
      expect(mail.body.encoded).to match(post.message)
    end

    it 'sends the email' do
      expect { mail.deliver_now }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'logo attachment is added' do
      expect(mail.attachments.count).to eq(1)
    end
  end
end