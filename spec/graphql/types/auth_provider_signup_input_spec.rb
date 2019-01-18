# frozen_string_literal: true

RSpec.describe Types::AuthProviderSignupInput do
  set_graphql_type

  it "has a :name input field of String type" do
    expect(subject.arguments['name'].type.to_type_signature).to eq('String')
  end

  it "has an :email input field of EmailAddress type" do
    expect(subject.arguments['email'].type.to_type_signature).to eq('EmailAddress')
  end

  it "has an :password input field of String type" do
    expect(subject.arguments['password'].type.to_type_signature).to eq('String')
  end

  it "has an :passwordConfirmation input field of String type" do
    expect(subject.arguments['passwordConfirmation'].type.to_type_signature).to eq('String')
  end
end
