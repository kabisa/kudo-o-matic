# frozen_string_literal: true

RSpec.describe Types::ViewerType do
  set_graphql_type

  it "has a :self field of UserType!" do
    expect(subject.fields['self'].type.to_type_signature).to eq('User!')
  end
end
