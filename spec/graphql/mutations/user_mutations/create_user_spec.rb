# frozen_string_literal: true

RSpec.describe Mutations::UserMutation, ":createUser" do
  context "create valid user" do
    name = Faker::Name.first_name
    args = {
      credentials: {
        name: name,
        email: "#{name.downcase}@example.com",
        password: "password",
        password_confirmation: "password"
      }
    }

    it "creates a new user" do
      expect {
        subject.fields["createUser"].resolve(nil, args, nil)
      }.to change { User.count }.by(1)
    end

    it "returns a valid token" do
      result = subject.fields["createUser"].resolve(nil, args, nil)
      token = result.dig("token")
      expect(AuthToken.new.verify(token).keys).to eq([:ok])
    end

    it "token matches user" do
      result = subject.fields["createUser"].resolve(nil, args, nil)
      token = result.dig("token")
      payload = AuthToken.new.verify(token)
      user_id = result.dig("user").id
      expect(payload.dig(:ok, :id)).to eq(user_id)
    end

    it "sends a confirmation instruction and welcome email" do
      expect do
        subject.fields["createUser"].resolve(nil, args, nil)
      end.to change {
        ActiveJob::Base.queue_adapter.enqueued_jobs.size
      }.by(2)

      expect(ActiveJob::Base.queue_adapter.enqueued_jobs.last(2)[0][:args]).to include('UserMailer', 'welcome_email', 'deliver_now')
      expect(ActiveJob::Base.queue_adapter.enqueued_jobs.last(2)[1][:args]).to include('KudosDeviseMailer', 'confirmation_instructions', 'deliver_now')
    end
  end

  context "create invalid user" do
    args = { credentials: {} }

    it "raises an ExecutionError if user is not saved" do
      expect {
        subject.fields["createUser"].resolve(nil, args, nil)
      }.to raise_error(GraphQL::ExecutionError)
    end
  end
end
