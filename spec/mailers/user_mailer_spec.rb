require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  let!(:user) { create(:user) }

  context 'invite email' do
    let(:team) { create(:team) }
    let(:user_mail) { 'email@example.com' }
    let(:mail) { described_class.invite_email(user_mail, team) }

    it 'renders the subject' do
      expect(mail.subject).to eq("You've been invited to join the Kudos-o-Matic")
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq([user_mail])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq(['example@mail.com'])
    end

    it 'sends the email' do
      expect { mail.deliver_now }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'logo attachment is added' do
      expect(mail.attachments.count).to eq(1)
    end
  end

  context 'welcome email' do
    let(:mail) { described_class.welcome_email(user) }

    it 'renders the subject' do
      expect(mail.subject).to eq('Welcome to the ₭udo-o-Matic!')
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq([user.email])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq(['example@mail.com'])
    end

    it 'sends the email' do
      expect { mail.deliver_now }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'logo attachment is added' do
      expect(mail.attachments.count).to eq(1)
    end
  end
end