RSpec.describe Types::ImageType do
  set_graphql_type

  it 'has an :imageUrl field of String type' do
    expect(subject.fields['imageUrl'].type.to_type_signature).to eq('String!')
  end

  it 'has an :imageThumbnailUrl field of String type' do
    expect(subject.fields['imageThumbnailUrl'].type.to_type_signature).to eq('String!')
  end
end
