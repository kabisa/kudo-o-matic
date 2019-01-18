# frozen_string_literal: true

RSpec.describe Types::AuthenticateType do
  set_graphql_type

  it "has an :token field of String type" do
    expect(subject.fields['token'].type.to_type_signature).to eq('String')
  end

  it "has an :user field of UserType" do
    expect(subject.fields['user'].type.to_type_signature).to eq('User')
  end
end
