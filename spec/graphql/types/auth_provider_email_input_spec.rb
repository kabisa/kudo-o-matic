# frozen_string_literal: true

RSpec.describe Types::AuthProviderEmailInput do
  set_graphql_type

  it "has an :email input field of EmailAddress! type" do
    expect(subject.arguments['email'].type.to_type_signature).to eq('EmailAddress!')
  end
end
