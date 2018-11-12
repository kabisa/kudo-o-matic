# frozen_string_literal: true

RSpec.describe Mutations::UserMutation, ":resetPassword" do
  let!(:user) { create(:user, admin: true) }

  context "request to reset password for existing user" do
    let(:args) { { credentials: { email: user.email } } }

    it "sends email instructions to reset password" do
      expect do
        subject.fields["resetPassword"].resolve(nil, args, nil)
      end.to change{ ActionMailer::Base.deliveries.count }.by(1)
    end
  end

  context "request to reset password for non-existing user" do
    let(:args) { { credentials: { email: "fake@mail.com" } } }

    it "doesn't send an email and returns nil" do
      query_result = subject.fields["resetPassword"].resolve(nil, args, nil)

      expect { query_result }.to_not change{ ActionMailer::Base.deliveries.count }

      expect(query_result).to be_nil
    end
  end
end
