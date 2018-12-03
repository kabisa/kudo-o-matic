# frozen_string_literal: true

RSpec.describe Mutations::UserMutation, ":newPassword" do
  let(:user) { create(:user) }

  context 'authenticated user' do
    let!(:ctx) { { current_user: user } }

    describe 'valid current password' do
      it "resets the password" do
        args = {
          current_password: "password",
          new_password: "newpassword",
          new_password_confirmation: "newpassword"
        }

        query_result = subject.fields["resetPassword"].resolve(nil, args, ctx)

        expect(query_result.password).to eq("newpassword")
      end

      it "returns an error if new password is not matching" do
        args = {
          current_password: "password",
          new_password: "newpassword",
          new_password_confirmation: "otherpassword"
        }

        expect do
          subject.fields["resetPassword"].resolve(nil, args, ctx)
        end.to raise_error(GraphQL::ExecutionError, "Password confirmation doesn't match Password")
      end
    end

    describe 'invalid current password' do
      it 'returns an error if current password is invalid' do
        args = {
          current_password: "wrongpassword",
          new_password: "newpassword",
          new_password_confirmation: "newpassword"
        }

        expect do
          subject.fields["resetPassword"].resolve(nil, args, ctx)
        end.to raise_error(GraphQL::ExecutionError, 'Invalid current password')
      end
    end
  end

  context 'unauthenticated user' do
    let!(:ctx) { { current_user: nil } }

    it "can\'t reset the password" do
      args = {
        current_password: "password",
        new_password: "newpassword",
        new_password_confirmation: "newpassword"
      }

      expect do
        subject.fields["resetPassword"].resolve(nil, args, ctx)
      end.to raise_error(GraphQL::ExecutionError, 'Authentication required')
    end
  end
end
