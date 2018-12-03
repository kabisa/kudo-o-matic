# frozen_string_literal: true

RSpec.describe Mutations::UserMutation, ":newPassword" do
  let!(:user) { create(:user, admin: true) }

  context "valid reset password token" do
    describe "create a new password" do
      let(:reset_password_token) { user.send_reset_password_instructions }
      let(:args) {
        {
          reset_password_token: reset_password_token,
          password: "newpassword",
          password_confirmation: "newpassword"
        }
      }

      it "sets the new password" do
        query_result = subject.fields["newPassword"].resolve(nil, args, nil)

        expect(query_result.password).to eq("newpassword")
      end
    end
  end


  context "invalid reset password token" do
    describe "create a new password" do
      let(:reset_password_token) { "faketoken" }
      let(:args) do
        {
            reset_password_token: reset_password_token,
            password: "newpassword",
            password_confirmation: "newpassword"
        }
      end

      it "returns nil" do
        query_result = subject.fields["newPassword"].resolve(nil, args, nil)

        expect(query_result).to be_nil
      end
    end
  end
end
