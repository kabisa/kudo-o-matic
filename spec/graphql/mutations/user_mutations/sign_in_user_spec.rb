# frozen_string_literal: true

RSpec.describe Mutations::UserMutation, ":signInUser" do
  let(:user) { create(:user) }

  it "authenticates user" do
    args = { credentials: { email: user.email, password: user.password } }
    ctx = { current_user: user }

    result = subject.fields["signInUser"].resolve(nil, args, ctx)

    expect(result.token).to be_present
    expect(result.user).to eq(user)
  end

  it "is nil when invalid email" do
    args = { credentials: { email: "invalid@email.com", password: user.password } }
    ctx = { current_user: user }

    result = subject.fields["signInUser"].resolve(nil, args, ctx)

    expect(result).to be_nil
  end

  it "is nil when invalid password" do
    args = { credentials: { email: user.email, password: "invalidpassword" } }
    ctx = { current_user: user }

    result = subject.fields["signInUser"].resolve(nil, args, ctx)

    expect(result).to be_nil
  end

  describe "JWT authentication" do
    let(:args) { { credentials: { email: user.email, password: user.password } } }
    let(:ctx) { { current_user: user } }

    it "returns a valid token" do
      result = subject.fields["signInUser"].resolve(nil, args, ctx)
      token = result.dig("token")

      expect(AuthToken.new.verify(token).keys).to eq([:ok])
    end

    it "token matches user" do
      result = subject.fields["signInUser"].resolve(nil, args, ctx)
      token = result.dig("token")
      payload = AuthToken.new.verify(token)
      user_id = result.dig("user").id

      expect(payload.dig(:ok, :id)).to eq(user_id)
    end
  end
end
