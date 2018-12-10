# frozen_string_literal: true

RSpec.describe Mutations::UserMutation, ":forgotPassword" do
  let!(:user) { create(:user, admin: true) }

  context "request to reset password for existing user" do
    let(:args) { { credentials: { email: user.email } } }

    it "sends email instructions to reset password" do
      expect do
        subject.fields["forgotPassword"].resolve(nil, args, nil)
      end.to change { ActiveJob::Base.queue_adapter.enqueued_jobs.size }.by(1)

      expect(ActiveJob::Base.queue_adapter.enqueued_jobs.last[:args]).to include('KudosDeviseMailer', 'reset_password_instructions', 'deliver_now')
    end
  end

  context "request to reset password for non-existing user" do
    let(:args) { { credentials: { email: "fake@mail.com" } } }

    it "doesn't send an email and returns nil" do
      query_result = subject.fields["forgotPassword"].resolve(nil, args, nil)

      expect { query_result }.to_not change{ ActiveJob::Base.queue_adapter.enqueued_jobs.size }

      expect(query_result).to be_nil
    end
  end
end
