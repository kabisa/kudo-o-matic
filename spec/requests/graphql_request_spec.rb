RSpec.describe "GraphQL" do
  it 'returns a 200 if the authentication header is missing' do
    headers = {}
    post '/graphql', :headers => headers
    expect(response.status).to be(200)
  end

  it 'returns a 200 if the authentication header has no value' do
    headers = { :Authorization => '' }
    post '/graphql', :headers => headers
    expect(response.status).to be(200)
  end

  it 'returns a 400 if the authentication header doesnt follow the pattern <something> <token>' do
    headers = { :Authorization => 'notBearer' }

    post '/graphql', :headers => headers
    expect(response.status).to be(400)
    parsed_body = JSON.parse(response.body)

    expect(parsed_body['error']).to eq('invalid_request')
    expect(parsed_body['error_description']).to eq('Invalid header format')
  end

  it 'returns a 401 if the token is invalid' do
    headers = { :Authorization => 'Bearer fakeToken' }

    post '/graphql', :headers => headers
    expect(response.status).to be(401)
    parsed_body = JSON.parse(response.body)

    expect(parsed_body['error']).to eq('invalid_token')
  end

  it 'returns a 401 if the token is expired' do
    headers = { :Authorization => 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjEiLCJleHBpcmVzX2luIjoxNTg2MjYyMTUyfQ.lPj5NiKarfX_cy2JIRp----89IEkFqZGVoo4jTnqM8c' }

    post '/graphql', :headers => headers
    expect(response.status).to be(401)
    parsed_body = JSON.parse(response.body)

    expect(parsed_body['error']).to eq('invalid_token')
  end
end