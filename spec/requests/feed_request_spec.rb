RSpec.describe "RSS Feed" do
  it 'renders the correct template' do
    team = create(:team)

    get "/#{team.slug}/feed/#{team.rss_token}"
    expect(response).to render_template('feed/index')
  end

  it 'returns a 404 if the team doesnt exist' do
    team = create(:team)

    get "/FakeTeam/feed/#{team.rss_token}"
    expect(response).to render_template('layouts/404')
    expect(response.status).to be(404)
  end

  it 'returns a 404 if the rss token is incorrect' do
    team = create(:team)

    get "/#{team.slug}/feed/FakeRssToken"
    expect(response).to render_template('layouts/404')
    expect(response.status).to be(404)
  end
end