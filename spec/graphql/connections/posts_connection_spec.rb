# frozen_string_literal: true

require "graphlient"

RSpec.describe Connections::PostsConnection do
  set_graphql_type

  it "has a :totalCount field that returns a Int type" do
    expect(subject.fields['totalCount'].type.to_type_signature).to eq('Int!')
  end
end
