# frozen_string_literal: true

RSpec.describe Mutations::ForgotPasswordMutation do
  set_graphql_type

  let!(:user) { create(:user) }
  let(:context) { {} }
  let(:variables) { { email: user.email } }

  let(:result) do
    res = KudoOMaticSchema.execute(
      mutation_string,
      context: context,
      variables: variables
    )
    res
  end

  let(:mutation_string) do
    %( mutation { forgotPassword(
      credentials: {
        email: "#{variables[:email]}"
      }
    ) { email } } )
  end

  describe 'existing user forgot password' do
    it 'returns the email' do
      expect(result['data']['forgotPassword']['email']).to eq(user.email)
    end

    it 'sends email instructions to reset password' do
      expect { result }.to change { ActiveJob::Base.queue_adapter.enqueued_jobs.size }.by(1)
      expect(ActiveJob::Base.queue_adapter.enqueued_jobs.last[:args]).to include('KudosDeviseMailer', 'reset_password_instructions', 'deliver_now')
    end
  end

  describe 'non-existing email' do
    let(:variables) { { email: 'fakemail@example.com' } }

    it 'returns the email' do
      expect(result['data']['forgotPassword']['email']).to eq('fakemail@example.com')
    end

    it "doesn't send an email" do
      expect { result }.to_not change { ActiveJob::Base.queue_adapter.enqueued_jobs.size }
    end
  end
end