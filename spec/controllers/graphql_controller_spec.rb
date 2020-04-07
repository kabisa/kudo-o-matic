RSpec.describe GraphqlController do

  describe 'Authentication' do
    it 'should return a 400 if the authentication header is missing' do
      post :execute, params: {}
      expect(response.status).to be(400)
      parsed_body = JSON.parse(response.body)

      expect(parsed_body['error']).to eq('invalid_request')
      expect(parsed_body['error_description']).to eq('Missing auth header')
    end

    it 'should return a 400 if the authentication header has no value' do
      request.headers['Authorization'] = ''
      post :execute
      expect(response.status).to be(400)
      parsed_body = JSON.parse(response.body)

      expect(parsed_body['error']).to eq('invalid_request')
      expect(parsed_body['error_description']).to eq('Missing auth header')
    end

    it 'should return a 400 if the authentication header doesnt include \'Bearer\'' do
      request.headers['Authorization'] = 'NotBearer'
      post :execute
      expect(response.status).to be(400)
      parsed_body = JSON.parse(response.body)

      expect(parsed_body['error']).to eq('invalid_request')
      expect(parsed_body['error_description']).to eq('Invalid header format')
    end

    it 'should return a 400 if the authentication header doesnt include a token' do
      request.headers['Authorization'] = 'Bearer '
      post :execute
      expect(response.status).to be(400)
      parsed_body = JSON.parse(response.body)

      expect(parsed_body['error']).to eq('invalid_request')
      expect(parsed_body['error_description']).to eq('Missing token')
    end

    it 'should return a 401 if the token is invalid' do
      request.headers['Authorization'] = 'Bearer fakeToken'
      post :execute
      expect(response.status).to be(401)
      parsed_body = JSON.parse(response.body)

      expect(parsed_body['error']).to eq('invalid_token')
    end

    it 'should return a 401 if the token is expired' do
      request.headers['Authorization'] = 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjEiLCJleHBpcmVzX2luIjoxNTg2MjYyMTUyfQ.lPj5NiKarfX_cy2JIRp----89IEkFqZGVoo4jTnqM8c'
      post :execute
      expect(response.status).to be(401)
      parsed_body = JSON.parse(response.body)

      expect(parsed_body['error']).to eq('invalid_token')
    end
  end
end