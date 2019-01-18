# frozen_string_literal: true

RSpec.describe Types::AuthProviderSigninInput do
  set_graphql_type

  it "has an :email input field of EmailAddress! type" do
    expect(subject.arguments['email'].type.to_type_signature).to eq('EmailAddress!')
  end

  it "has an :password input field of String! type" do
    expect(subject.arguments['password'].type.to_type_signature).to eq('String!')
  end
end
