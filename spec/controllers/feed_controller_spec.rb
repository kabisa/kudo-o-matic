RSpec.describe FeedController do

  describe 'GET index' do
    it 'renders the correct template' do
      team = create(:team)

      get :index, params: {team: team.slug, rss_token: team.rss_token}
      expect(response).to render_template('feed/index')
    end

    it 'returns a 404 if the team doesnt exist' do
      team = create(:team)

      get :index, params: {team: 'SomeFakeTeamTeam', rss_token: team.rss_token}
      expect(response).to render_template('layouts/404')
      expect(response.status).to be(404)
    end

    it 'returns a 404 if the rss token is incorrect' do
      team = create(:team)

      get :index, params: {team: team.slug, rss_token: 'FakeRssToken'}
      expect(response).to render_template('layouts/404')
      expect(response.status).to be(404)
    end
  end
end