class FeedController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    request.format = :atom
    if Team.find_by_rss_token(params[:rss_token]).nil?
      render 'layouts/404', status: 404, formats: :html
    end

    @team = Team.find_by_slug(params[:team])
    @transactions = Transaction.where(team: @team).last(25)
    respond_to do |format|
      format.atom
    end
  end
end
